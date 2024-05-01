import re
from rest_framework.exceptions import AuthenticationFailed
from django.urls import path, include, reverse
from django.contrib import admin
from project.settings import API_KEY
from rest_framework.response import Response

class APIKeyAuthentication(object):
  def __init__(self, get_response):
    self.get_response = get_response

  def __call__(self, request):
    paths = request.path.split("/")

    if ("admin" in paths):
      return self.get_response(request)
    
    api_key = request.META.get('HTTP_AUTHORIZATION')
      
    if not api_key:
      raise AuthenticationFailed({'error':'Missing API key'})
      
    if api_key!=API_KEY:
      raise AuthenticationFailed({'error':'Invalid API key'})
      
    return self.get_response(request)

