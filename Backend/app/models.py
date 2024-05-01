from django.db import models
from django.utils import timezone
from django.contrib.auth.models import User

class Owner(models.Model):
    name = models.CharField(max_length=100)
    civil_id = models.CharField(max_length=50, unique=True)
    contact_phone = models.CharField(max_length=20, default=None, null=True)
    contact_email = models.CharField(max_length=100, default=None, null=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE)

class Zoning(models.Model):
    zoning_type = models.CharField(max_length=50)
    regulations =models.TextField()
    
class LandParcel(models.Model):
    parcel_number = models.CharField(max_length=50, unique=True)
    owner = models.ForeignKey(Owner, on_delete=models.CASCADE)
    zoning = models.ForeignKey(Zoning, on_delete=models.CASCADE)
    area = models.DecimalField(max_digits=10, decimal_places=3)
    city = models.CharField(max_length=50)
    address = models.CharField(max_length=200)
    geometry_latitude = models.FloatField()
    geometry_longitude = models.FloatField()

class Delivery(models.Model):
    parcel = models.ForeignKey(LandParcel, on_delete=models.CASCADE)
    created_date = models.DateTimeField(default=timezone.now)
    delivery_date = models.DateTimeField(default=None , null=True)
    delivery_status = models.CharField(max_length=50, choices=[
        ('created', 'Created'),
        ('in_progress', 'In Progress'),
        ('delivered', 'Delivered'),
        ('failed', 'Failed'),
    ], default='created')
    delivery_notes = models.TextField(blank=True, null=True)
