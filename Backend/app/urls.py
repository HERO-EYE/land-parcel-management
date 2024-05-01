from django.urls import path
from . import views

urlpatterns = [
    path('parcels/', views.parcels_list, name='parcels_list'),
    path('parcels/<int:pk>/', views.parcel_detail, name='parcel_detail'),
    path('parcels/add/', views.parcel_create, name='parcel_create'),
    path('parcels/<int:pk>/update/', views.parcel_update, name='parcel_update'),
    path('parcels/<int:pk>/delete/', views.parcel_delete, name='parcel_delete'),
    path('parcels/nearby/', views.parcel_nearby, name='parcel_nearby'),
    path('parcels/area/', views.parcel_between_area, name='parcel_nearby'),
    path('zoning/', views.zonings_list, name='zonings_list'),
    path('zoning/<int:pk>/', views.zoning_detail, name='zoning_detail'),
    path('zoning/add/', views.zoning_create, name='zoning_create'),
    path('zoning/<int:pk>/update/', views.zoning_update, name='zoning_update'),
    path('zoning/<int:pk>/delete/', views.zoning_delete, name='zoning_delete'),
    path('owner/', views.owners_list, name='owners_list'),
    path('owner/<int:pk>/', views.owner_detail, name='owner_detail'),
    path('owner/add/', views.owner_create, name='owner_create'),
    path('owner/<int:pk>/update/', views.owner_update, name='owner_update'),
    path('owner/<int:pk>/delete/', views.owner_delete, name='owner_delete'),
    path('delivery/', views.delivery_list, name='create_delivery'),
    path('delivery/<int:pk>/', views.delivery_detail, name='delivery_detail'),
    path('delivery/add/', views.delivery_create, name='delivery_create'),
    path('delivery/<int:pk>/update/', views.delivery_update, name='delivery_update'),
    path('delivery/<int:pk>/delete/', views.delivery_delete, name='delivery_delete'),
    path('statistics/', views.statistics, name='general_statistics'),
    path('login/', views.login_view, name='login'),
]