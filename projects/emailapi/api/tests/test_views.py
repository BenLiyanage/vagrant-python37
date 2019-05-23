from django.test import TestCase
from api.views import Email, InvalidParametersException, NulLRequiredFieldException
from django.test.client import RequestFactory
import json


class EmailTestCase(TestCase):
    def test_post(self):
        data = {
            "to": "ben@perfectresolution.com",
            "to_name": "Mr. Fake",
            "from": "noreply@mybrightwheel.com",
            "from_name": "Brightwheel",
            "subject": "A Message from Brightwheel",
            "body": "<h1>Your Bill</h1><p>$10</p>"
        }

        request = self.request_from_data(data)
        email = Email()
        email.post(request)

    def request_from_data(self, data):
        request_factory = RequestFactory()

        request = request_factory.post(
            '/api/email',
            data=json.dumps(data),
            content_type='application/json',
        )
        return request

    def test_post_invalid_parameters(self):
        data = {'a': 'banana'}
        request = self.request_from_data(data)
        email = Email()
        with self.assertRaises(InvalidParametersException):
            email.post(request)

    def test_post_invalid_data(self):
        data = {
            "to": "",
            "to_name": "",
            "from": "",
            "from_name": "",
            "subject": "",
            "body": ""
        }
        request = self.request_from_data(data)
        email = Email()
        with self.assertRaises(NulLRequiredFieldException):
            email.post(request)
