#!/usr/bin/env python

# -----------------------------------------------------------------------------
# A python sample code for sending a bulk report to the TNS.
#
# Usage: tnsAPI.py <api key> <example json file>
#
# Written by Ken Smith, May 2016
# -----------------------------------------------------------------------------

# The only required additional python module for this code is "requests" (pip install requests).
import requests
import json
import time
import logging

# Hurl the log info into a default log file.  We'll use debug level by default.
logging.basicConfig(filename='/tmp/tns.log', format='%(asctime)s %(message)s', datefmt='%Y-%m-%d %H:%M:%S', level=logging.DEBUG)
logger = logging.getLogger(__name__)

AT_REPORT_FORM = "bulk-report"
AT_REPORT_REPLY = "bulk-report-reply"
TNS_ARCHIVE = {'OTHER': '0', 'SDSS': '1', 'DSS': '2'}

httpErrors = {
    304: 'Error 304: Not Modified: There was no new data to return.',
    400: 'Error 400: Bad Request: The request was invalid. An accompanying error message will explain why.',
    403: 'Error 403: Forbidden: The request is understood, but it has been refused. An accompanying error message will explain why',
    404: 'Error 404: Not Found: The URI requested is invalid or the resource requested, such as a category, does not exists.',
    500: 'Error 500: Internal Server Error: Something is broken.',
    503: 'Error 503: Service Unavailable.'
}

class TNSClient(object):
    """Send Bulk TNS Request."""

    def __init__(self, baseURL, options = {}):
        """
        Constructor. 

        :param baseURL: Base URL of the TNS API
        :param options:  (Default value = {})

        """
        
        #self.baseAPIUrl = TNS_BASE_URL_SANDBOX
        self.baseAPIUrl = baseURL
        self.generalOptions = options

    def buildUrl(self, resource):
        """
        Build the full URL

        :param resource: the resource requested
        :return complete URL

        """
        return self.baseAPIUrl + resource

    def buildParameters(self, parameters = {}):
        """
        Merge the input parameters with the default parameters created when
        the class is constructed.

        :param parameters: input dict  (Default value = {})
        :return p: merged dict

        """
        p = self.generalOptions.copy()
        p.update(parameters)
        return p

    def jsonResponse(self, r):
        """
        Send JSON response given requests object. Should be a python dict.

        :param r: requests object - the response we got back from the server
        :return d: json response converted to python dict

        """

        d = {}
        # What response did we get?
        message = None
        status = r.status_code

        if status != 200:
            try:
                message = httpErrors[status]
            except ValueError, e:
                message = 'Error %d: Undocumented error' % status

        if message is not None:
            logger.warn(message)
            return d
        
        # Did we get a JSON object?
        try:
            d = r.json()
        except ValueError, e:
            logger.error(e)
            d = {}
            return d


        # If so, what error messages if any did we get?

        logger.info(json.dumps(d, indent=4, sort_keys=True))

        if 'id_code' in d.keys() and 'id_message' in d.keys() and d['id_code'] != 200:
            logger.error("Bad response: code = %d, error = '%s'" % (d['id_code'], d['id_message']))
        return d


    def sendBulkReport(self, options):
        """
        Send the JSON TNS request

        :param options: the JSON TNS request
        :return: dict

        """
        feed_url = self.buildUrl(AT_REPORT_FORM);
        feed_parameters = self.buildParameters({'data': (None, json.dumps(options))});
        
        # The requests.post method needs to receive a "files" entry, not "data".  And the "files"
        # entry needs to be a dictionary of tuples.  The first value of the tuple is None.
        r = requests.post(feed_url, files = feed_parameters, timeout = 300)
        # Construct the JSON response and return it.
        return self.jsonResponse(r)

    def bulkReportReply(self, options):
        """
        Get the report back from the TNS

        :param options: dict containing the report ID
        :return: dict

        """
        feed_url = self.buildUrl(AT_REPORT_REPLY);
        feed_parameters = self.buildParameters(options);

        r = requests.post(feed_url, files = feed_parameters, timeout = 300)
        return self.jsonResponse(r)


def addBulkReport(report, tnsBaseURL, tnsApiKey):
    """
    Send the report to the TNS

    :param report: 
    :param tnsBaseURL: TNS base URL
    :param tnsApiKey: TNS API Key
    :return reportId: TNS report ID

    """
    feed_handler = TNSClient(tnsBaseURL, {'api_key': (None, tnsApiKey)})
    reply = feed_handler.sendBulkReport(report)

    reportId = None

    if reply:
        try:
            reportId = reply['data']['report_id']
        except ValueError, e:
            logger.error("Empty response. Something went wrong.  Is the API Key OK?")
        except KeyError, e:
            logger.error("Cannot find the data key. Something is wrong.")

    return reportId


def getBulkReportReply(reportId, tnsBaseURL, tnsApiKey):
    """
    Get the TNS response for the specified report ID

    :param reportId: 
    :param tnsBaseURL: TNS base URL
    :param tnsApiKey: TNS API Key
    :return request: The original request
    :return response: The TNS response

    """
    feed_handler = TNSClient(tnsBaseURL, {'api_key': (None, tnsApiKey)})
    reply = feed_handler.bulkReportReply({'report_id': (None, str(reportId))})

    request = None
    response = None
    # reply should be a dict
    if (reply and 'id_code' in reply.keys() and reply['id_code'] == 404):
        logger.warn("Unknown report.  Perhaps the report has not yet been processed.")

    if (reply and 'id_code' in reply.keys() and reply['id_code'] == 200):
        try:
            request = reply['data']['received_data']['at_report']
            response = reply['data']['feedback']['at_report']
        except ValueError, e:
            logger.error("Cannot find the response feedback payload.")

    return request, response


# Note that the following code uses the low level API rather than the two
# wrapper methods written above. It is designed to look as close to the PHP
# code as possible.

def main(argv = None):
    """
    Test harness.  Check that the code works as designed.

    :param argv:  (Default value = None)

    """

    import sys

    if argv is None:
        argv = sys.argv

    usage = "Usage: %s <api key> <example json file>" % argv[0]
    if len(argv) != 3:
        sys.exit(usage)

    apiKey = argv[1]
    exampleJsonFile = argv[2]

    with open(exampleJsonFile) as jsonFile:
        at_rep_example = json.load(jsonFile)

    TNS_BASE_URL_SANDBOX = "https://sandbox-tns.weizmann.ac.il/api/"
    TNS_BASE_URL_REAL    = "https://wis-tns.weizmann.ac.il/api/"

    SLEEP_SEC = 1
    LOOP_COUNTER = 10

    feed_handler = TNSClient(TNS_BASE_URL_SANDBOX, {'api_key': (None, apiKey)})
    js = at_rep_example
    logger.debug('EXAMPLE BULK AT REPORT')
    logger.debug(json.dumps(js, indent=4, sort_keys=True))
    response = feed_handler.sendBulkReport(js)
    if response:
        try:
            report_id = response['data']['report_id']
        except ValueError, e:
            logger.error("Empty response. Something went wrong.  Is the API Key OK?")
    else:
        # We got no valid JSON back
        logger.error("Empty response. Something went wrong.  Is the API Key OK?")
        return 1

    report_id = response['data']['report_id']
    logger.info("REPORT ID = %s" % report_id)

    counter = 0
    while True:
        time.sleep(SLEEP_SEC)
        response = feed_handler.bulkReportReply({'report_id': (None, str(report_id))})
        counter += 1
        if (response and 'id_code' in response.keys() and response['id_code'] != 404) or counter >= LOOP_COUNTER:
            break

    logger.info("Done")
    return 0


if __name__ == '__main__':
    main()
