from django.contrib import admin
from .models import Owner, Zoning, LandParcel

admin.site.register(Owner)
admin.site.register(Zoning)
admin.site.register(LandParcel)