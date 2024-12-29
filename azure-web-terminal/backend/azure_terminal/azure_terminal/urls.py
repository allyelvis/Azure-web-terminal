from django.urls import path
from .views import execute_command

urlpatterns = [
    path('api/execute', execute_command)
]
