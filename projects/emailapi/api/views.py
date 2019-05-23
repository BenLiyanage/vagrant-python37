from django.views import View
import requests
from os import environ
from django.http import HttpResponse
from django.views.decorators.csrf import csrf_exempt
import json
from django.utils.html import strip_tags

class Email(View):
    def get(self, request):
        return HttpResponse()

    @csrf_exempt
    def post(self, request):
        data = json.loads(request.body)
        self.validate_data(data)
        api_key = environ['MAILGUN_API_TOKEN']
        response = requests.post(
            "https://api.mailgun.net/v3/sandboxdfea252d2fa74aed89b24b726be60a35.mailgun.org/messages",
            auth=("api", api_key),
            data={
                "from": self.format_email(data['from_name'], data['from']),
                "to": self.format_email(data['to_name'], data['to']),
                "subject": data['subject'],
                "html": data['body'],
                "text": strip_tags(data['body'])
            }
        )
        response.raise_for_status()
        return HttpResponse()

    def format_email(self, name, email):
        # print("{} <{}>".format(name, email))
        return "{} <{}>".format(name, email)

    def validate_data(self, data):
        if [*data.keys()] != ['to', 'to_name', 'from', 'from_name', 'subject', 'body']:
            raise InvalidParametersException()

        for key, value in data.items():
            if value == "":
                raise NulLRequiredFieldException()


class InvalidParametersException(Exception):
    pass


class NulLRequiredFieldException(Exception):
    pass
