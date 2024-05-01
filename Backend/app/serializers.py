from rest_framework import serializers
from .models import Owner, Zoning, LandParcel, Delivery

class OwnerSerializer(serializers.ModelSerializer):
    class Meta:
        model = Owner
        fields = '__all__'
    
    def update(self, instance, validated_data):
        updated = False
        for key in validated_data:
            if hasattr(instance, key):
                if(getattr(instance, key) != validated_data[key]):
                    setattr(instance, key, validated_data[key])
                    updated = True
                    
        instance.save()
        return instance, updated
           
class ZoningSerializer(serializers.ModelSerializer):
    class Meta:
        model = Zoning
        fields = '__all__'
    
    def update(self, instance, validated_data):
        updated = False
        for key in validated_data:
            if hasattr(instance, key):
                if(getattr(instance, key) != validated_data[key]):
                    setattr(instance, key, validated_data[key])
                    updated = True
                    
        instance.save()
        return instance, updated

class LandParcelSerializer(serializers.ModelSerializer):

    class Meta:
        model = LandParcel
        fields = '__all__'
    
    def update(self, instance, validated_data):
        updated = False
        for key in validated_data:
            if hasattr(instance, key):
                if(getattr(instance, key) != validated_data[key]):
                    setattr(instance, key, validated_data[key])
                    updated = True
                    
        instance.save()
        return instance, updated

class DeliverySerializer(serializers.ModelSerializer):

    class Meta:
        model = Delivery
        fields = '__all__'
    
    def update(self, instance, validated_data):
        updated = False
        for key in validated_data:
            if hasattr(instance, key):
                if(getattr(instance, key) != validated_data[key]):
                    setattr(instance, key, validated_data[key])
                    updated = True
                    
        instance.save()
        return instance, updated
