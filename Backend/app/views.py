from django.shortcuts import render
from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import LandParcel, Zoning, Owner, Delivery
from .serializers import LandParcelSerializer, ZoningSerializer, OwnerSerializer, DeliverySerializer
from django.db.models import Count, Avg
from math import radians, sin, cos, sqrt, atan2
from django.contrib.auth import authenticate, login
from django.contrib.auth.models import User

@api_view(['POST'])
def login_view(request):
    if request.method == 'POST':
        username = request.POST['username']
        password = request.POST['password']
        user = authenticate(request, username=username, password=password)
        if user is not None:
            login(request, user)
            owner = Owner.objects.get(user_id=user.id)
            owner_serializer = OwnerSerializer(owner)
            return Response({'success': owner_serializer.data})
        else:
            response = {'error','Invalid username or password'}
            return Response(response, status=status.HTTP_401_UNAUTHORIZED)

@api_view(['GET'])
def parcels_list(request):
    if request.method == 'GET':
        zoning = request.GET.get('zoning')
        owner = request.GET.get('owner')
        if (zoning and is_int(zoning) and owner and is_int(owner)):
            parcels = LandParcel.objects.filter(zoning_id=zoning, owner_id=owner)
        elif (zoning and is_int(zoning)):
            parcels = LandParcel.objects.filter(zoning_id=zoning)
        elif (owner and is_int(owner)):
            parcels = LandParcel.objects.filter(owner_id=owner)
        else:
            parcels = LandParcel.objects.all()
        
        parcels_list = []
        for parcel in parcels:
            try:
                owner_obj = Owner.objects.get(id=parcel.owner_id)
            except Delivery.DoesNotExist:
                owner_obj = None
                
            try:
                zoning_obj = Zoning.objects.get(id=parcel.zoning.id)
            except Owner.DoesNotExist:
                zoning_obj = None
            
            try:
                delivery = Delivery.objects.get(parcel=parcel.id)
            except Delivery.DoesNotExist:
                delivery = None
            
            parcel_serialize = LandParcelSerializer(parcel)
            result = parcel_serialize.data
            if (owner_obj): result["owner"] = OwnerSerializer(owner_obj).data
            if (delivery): result["delivery"] = DeliverySerializer(delivery).data
            if (zoning_obj): result["zoning"] = ZoningSerializer(zoning_obj).data
            parcels_list.append(result)
        
        results = parcels_list
        return Response(results)
    
@api_view(['GET'])
def parcel_detail(request, pk):
    try:
        parcel = LandParcel.objects.get(pk=pk)
    except LandParcel.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)

    try:
        delivery = Delivery.objects.get(parcel=parcel.id)
    except Delivery.DoesNotExist:
        delivery = None
        
    try:
        owner = Owner.objects.get(id=parcel.owner.id)
    except Owner.DoesNotExist:
        owner = None
    
    try:
        zoning = Zoning.objects.get(id=parcel.zoning.id)
    except Owner.DoesNotExist:
        zoning = None
    
    if request.method == 'GET':
        serializer = LandParcelSerializer(parcel)
        results = serializer.data
        
        results["delivery"] = DeliverySerializer(delivery).data
        if (owner): results["owner"] = OwnerSerializer(owner).data
        if (zoning): results["zoning"] = ZoningSerializer(zoning).data
        
        return Response(results)

@api_view(['POST'])
def parcel_create(request):
    if request.method == 'POST':
        if 'owner' in request.data:
            owner_id = request.data["owner"]
        try:
            owner = Owner.objects.get(pk=owner_id)
        except Owner.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)
        
        if 'zoning' in request.data:
            zoning_id = request.data["zoning"]
        try:
            zoning = Zoning.objects.get(pk=zoning_id)
        except Owner.DoesNotExist:
            return Response({"error": "zoning does not exist"} ,status=status.HTTP_404_NOT_FOUND)
        
        serializer = LandParcelSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            
            delivery_data = {"parcel": serializer.data.get("id")}
            delivery_serializer = DeliverySerializer(data=delivery_data)
            if delivery_serializer.is_valid():
                delivery_serializer.save()
                
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['PUT'])
def parcel_update(request, pk):
    try:
        parcel = LandParcel.objects.get(pk=pk)
    except LandParcel.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)

    if request.method == 'PUT': 
        if 'owner' in request.data:
            owner_id = request.data["owner"]
        try:
            owner = Owner.objects.get(pk=owner_id)
        except Owner.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)
        
        if 'zoning' in request.data:
            zoning_id = request.data["zoning"]
        try:
            zoning = Zoning.objects.get(pk=zoning_id)
        except Owner.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)
        
        serializer = LandParcelSerializer(parcel)
        _, updated = serializer.update(parcel, request.data)
        if (updated):
            return Response(serializer.data)        
        return Response({"error":"failed to update!"}, status=status.HTTP_400_BAD_REQUEST)

@api_view(['DELETE'])
def parcel_delete(request, pk):
    try:
        parcel = LandParcel.objects.get(pk=pk)
    except LandParcel.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)

    if request.method == 'DELETE':
        parcel.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)

@api_view(['GET'])
def parcel_nearby(request):
    if request.method == 'GET':
        try:
            lat = request.GET.get('lat')
            lon = request.GET.get('lon')
            distance = request.GET.get('distance')
            if not is_float(lat) or not is_float(lon) or not is_float(distance):
                return Response(status=status.HTTP_400_BAD_REQUEST)
            
            parcels = LandParcel.objects.all()
            parcels_list = []
            for land in parcels:
                p1 = (float(lat), float(lon))
                p2 = (land.geometry_latitude , land.geometry_longitude)
                calc_distnace = calculate_distance(p1 ,p2)
                if (calc_distnace<= float(distance) ):
                    parcels_list.append(land)
            
            serializer = LandParcelSerializer(parcels_list, many=True)
            return Response(serializer.data)
        except Exception as e:
            return Response(status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET'])
def parcel_between_area(request):
    if request.method == 'GET':
        try:
            min_area = request.GET.get('min_area')
            max_area = request.GET.get('max_area')
            if not is_float(min_area) and not is_float(max_area):
                response = {"error":"min_area or max_area must be determined!"}
                return Response(response, status=status.HTTP_400_BAD_REQUEST)
            
            parcels = LandParcel.objects.all()
            parcels_list = []
            for land in parcels:
                if(is_float(min_area) and is_float(max_area)):
                    if (land.area>=float(min_area) and land.area<=float(max_area)):
                        parcels_list.append(land)
                if(is_float(min_area) and not is_float(max_area)):
                    if (land.area>=float(min_area)):
                        parcels_list.append(land)
                if(not is_float(min_area) and is_float(max_area)):
                    if (land.area<=float(max_area)):
                        parcels_list.append(land)
            
            serializer = LandParcelSerializer(parcels_list, many=True)
            return Response(serializer.data)
        except Exception as e:
            print(e)
            return Response(status=status.HTTP_400_BAD_REQUEST)
        
@api_view(['GET'])
def zonings_list(request):
    if request.method == 'GET':
        zonings = Zoning.objects.all()
        serializer = ZoningSerializer(zonings, many=True)
        return Response(serializer.data)

@api_view(['GET'])
def zoning_detail(request, pk):
    try:
        zoning = Zoning.objects.get(pk=pk)
    except Zoning.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)
    if request.method == 'GET':
        serializer = ZoningSerializer(zoning)
        return Response(serializer.data)

@api_view(['POST'])
def zoning_create(request):
    if request.method == 'POST':
        serializer = ZoningSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
                
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['PUT'])
def zoning_update(request, pk):
    try:
        zoning = Zoning.objects.get(pk=pk)
    except Zoning.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)

    if request.method == 'PUT':         
        serializer = ZoningSerializer(zoning)
        _, updated = serializer.update(zoning, request.data)
        if (updated):
            return Response(serializer.data)        
        return Response({"error":"failed to update!"}, status=status.HTTP_400_BAD_REQUEST)

@api_view(['DELETE'])
def zoning_delete(request, pk):
    try:
        zoning = Zoning.objects.get(pk=pk)
    except Zoning.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)

    if request.method == 'DELETE':
        zoning.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)

@api_view(['GET'])
def owners_list(request):
    if request.method == 'GET':
        owners = Owner.objects.all()
        serializer = OwnerSerializer(owners, many=True)
        return Response(serializer.data)

@api_view(['GET'])
def owner_detail(request, pk):
    try:
        owner = Owner.objects.get(pk=pk)
    except Owner.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)
    if request.method == 'GET':
        serializer = OwnerSerializer(owner)
        return Response(serializer.data)

@api_view(['POST'])
def owner_create(request):
    if request.method == 'POST':
        required = ["username", "password", "name", "civil_id"]
        for key in required:
            if (key not in request.data):
                return Response(status=status.HTTP_400_BAD_REQUEST)

        try:
            user = User.objects.create_user(username=request.data["username"],password=request.data["password"])
        except Exception as e:
            print(e)
            return Response(status=status.HTTP_400_BAD_REQUEST)

        if user.pk:
            owner_data = request.data.copy()
            if 'username' in owner_data: del owner_data['username']
            if 'password' in owner_data: del owner_data['password']

            owner_data["user"] = user.pk
        
            serializer = OwnerSerializer(data=owner_data)
            if serializer.is_valid():
                serializer.save()
                
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(status=status.HTTP_400_BAD_REQUEST)

@api_view(['PUT'])
def owner_update(request, pk):
    try:
        owner = Owner.objects.get(pk=pk)
    except Owner.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)

    if request.method == 'PUT':         
        serializer = OwnerSerializer(owner)
        _, updated = serializer.update(owner, request.data)
        if (updated):
            return Response(serializer.data)        
        return Response({"error":"failed to update!"}, status=status.HTTP_400_BAD_REQUEST)

@api_view(['DELETE'])
def owner_delete(request, pk):
    try:
        owner = Owner.objects.get(pk=pk)
    except Owner.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)

    if request.method == 'DELETE':
        owner.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)

@api_view(['GET'])
def delivery_list(request):
    if request.method == 'GET':
        delivery_status = request.GET.get('delivery_status')

        if (delivery_status):
            delivery = Delivery.objects.filter(delivery_status=delivery_status)
        else:
            delivery = Delivery.objects.all()
        serializer = DeliverySerializer(delivery, many=True)
        return Response(serializer.data)

@api_view(['GET'])
def delivery_detail(request, pk):
    try:
        delivery = Delivery.objects.get(pk=pk)
    except Delivery.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)

    if request.method == 'GET':
        serializer = LandParcelSerializer(delivery)
        return Response(serializer.data)

@api_view(['POST'])
def delivery_create(request):
    if request.method == 'POST':
        if 'parcel' in request.data:
            parcel_id = request.data["parcel"]
            try:
                parcel = LandParcel.objects.get(pk=parcel_id)
            except LandParcel.DoesNotExist:
                return Response(status=status.HTTP_404_NOT_FOUND)
            
            serializer = DeliverySerializer(data=request.data)
            if serializer.is_valid():
                serializer.save()
                return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['PUT'])
def delivery_update(request, pk):
    try:
        delivery = Delivery.objects.get(pk=pk)
    except Delivery.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)

    if 'parcel' in request.data:
        parcel_id = request.data["parcel"]
        try:
            parcel = LandParcel.objects.get(pk=parcel_id)
        except LandParcel.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)
        
    if request.method == 'PUT': 
        serializer = DeliverySerializer(delivery)
        _, updated = serializer.update(delivery, request.data)
        if (updated):
            return Response(serializer.data)        
        return Response({"error":"failed to update!"}, status=status.HTTP_400_BAD_REQUEST)

@api_view(['DELETE'])
def delivery_delete(request, pk):
    try:
        delivery = Delivery.objects.get(pk=pk)
    except Delivery.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)

    if request.method == 'DELETE':
        delivery.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)

@api_view(['GET'])
def statistics(request):
    try:
        if request.method == 'GET':
            parcels_per_zoning = {}
            zonnings = Zoning.objects.all()
            for zoning in zonnings:
                parcels = LandParcel.objects.filter(zoning_id=zoning.id)
                parcels_per_zoning[zoning.zoning_type] = len(list(parcels))
                
            avg_delivery_time = Delivery.objects.aggregate(avg_delivery=Avg('delivery_time'))
            
            zoning_delivery_times = Zoning.objects.annotate(zoning_avg_delivery_time=Avg("delivery_time"))
            zoning_avg_delivery_time = zoning_delivery_times[0].zoning_avg_delivery_time
            
            results = {
                "parcels_per_zoning": parcels_per_zoning,
                "avg_delivery_time": avg_delivery_time['avg_delivery'],
                "zoning_avg_delivery_time": zoning_avg_delivery_time
            }
            return Response(results)
    except Exception as e:
        print(e)
        return Response(status=status.HTTP_400_BAD_REQUEST)


def calculate_distance(p1 ,p2):
    R = 6371.0
    lat1 = p1[0]
    lon1 = p1[1]
    lat2 = p2[0]
    lon2 = p2[1]
    
    lat1_rad = radians(lat1)
    lon1_rad = radians(lon1)
    lat2_rad = radians(lat2)
    lon2_rad = radians(lon2)

    dlat = lat2_rad - lat1_rad
    dlon = lon2_rad - lon1_rad

    a = sin(dlat / 2)**2 + cos(lat1_rad) * cos(lat2_rad) * sin(dlon / 2)**2
    c = 2 * atan2(sqrt(a), sqrt(1 - a))
    distance = R * c
    return distance

def is_float(n):
    try:
        float_n = float(n)
    except:
        return False
    else:
        return True
    
def is_int(n):
    try:
        int_n = int(n)
    except:
        return False
    else:
        return True