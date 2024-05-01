# Land Parcel Management System

Welcome to the Land Parcel Management System! This system is designed to manage land parcels.

## Table of Contents

1. [Database Schema](#database-schema)
2. [API Endpoints](#api-endpoints)
3. [Deployment](#deployment)
4. [Usage](#usage)
5. [Demo](#demo)
6. [Mobile App](#app)

## Database Schema <a name="database-schema"></a>

The Land Parcel Management System uses the following database schema:

### Owners Table
- **id**: Primary Key, Auto-increment Integer
- **name**: CharField (max_length=100)
- **civil_id**: CharField (max_length=50)
- **contact_phone**: CharField (max_length=20)
- **contact_email**: CharField (max_length=100)
- **user**: Foreign Key to Django User model

### Zoning Table
- **id**: Primary Key, Auto-increment Integer
- **zoning_type**: CharField (max_length=50)
- **regulations**: TextField

### LandParcel Table
- **id**: Primary Key, Auto-increment Integer
- **parcel_number**: CharField (max_length=50, unique=True)
- **owner**: Foreign Key to Owners Table
- **zoning**: Foreign Key to Zoning Table
- **address**: CharField (max_length=255)
- **city**: CharField (max_length=20)
- **area**: DecimalField (max_digits=10, decimal_places=3)
- **geometry_latitude**: FloatField
- **geometry_longitude**: FloatField

### Delivery Table
- **id**: Primary Key, Auto-increment Integer
- **parcel**: Foreign Key to LandParcel Table
- **created_date**: DateTimeField(default=timezone.now)
- **delivery_date**: DateTimeField
- **delivery_status**: CharField (max_length=50)
- **delivery_notes**: TextField
  
## API Endpoints <a name="api-endpoints"></a>

The Land Parcel Management System provides the following API endpoints:

### Authorization

All endpoints are secured by this Authorization API key; pass it in the HTTP request headers.
- **Authorization**:
  ```bash
  eyJ0eXAiOiJKV1oiODZWEYm*4kdgra0n!z3t3*yea!d17bd
  ```

### Owners Endpoints

- **GET /api/owner/**
  - Description: Retrieves a list of all owners.
  
- **POST /api/owner/add/**
  - Description: Creates a new owner.
  - Parameters:
    - **username**: Owner's username
    - **password**: Owner's password
    - **name**: Owner's name
    - **civil_id**: Owner's civil ID
    - **contact_phone** (optional): Owner's contact phone
    - **contact_email** (optional): Owner's contact phone
    

- **GET /api/owner/{owner_id}/**
  - Description: Retrieves details of a specific owner by ID.

- **PUT /api/owner/{owner_id}/update**
  - Description: Updates details of a specific owner by ID.
  - Parameters:
    - **name** (optional): Owner's name
    - **civil_id** (optional): Owner's civil ID
    - **contact_phone** (optional): Owner's contact phone
    - **contact_email** (optional): Owner's contact phone

- **DELETE /api/owner/{owner_id}/delete**
  - Description: Deletes a specific owner by ID.

### Zoning Endpoints

- **GET /api/zoning/**
  - Description: Retrieves a list of all zoning regulations.

- **POST /api/zoning/add/**
  - Description: Creates new zoning regulations.
  - Parameters:
    - **zoning_type**: Type of zoning regulations
    - **regulations_details**: Details of zoning regulations

- **GET /api/zoning/{zoning_id}/**
  - Description: Retrieves details of specific zoning regulations by ID.

- **PUT /api/zoning/{zoning_id}/update/**
  - Description: Updates details of specific zoning regulations by ID.
  - Parameters:
    - **zoning_type**: Type of zoning regulations
    - **regulations_details**: Details of zoning regulations

- **DELETE /api/zoning/{zoning_id}/delete/**
  - Description: Deletes specific zoning regulations by ID.

### LandParcel Endpoints

- **GET /api/parcels/**
  - Description: Retrieves a list of all land parcels.

- **POST /api/parcels/add/**
  - Description: Creates a new land parcel.
  - Parameters:
    - **parcel_number**: a unique number of the parcel
    - **owner**: ID of the owner
    - **city**: City of the parcel
    - **address**: Address of the parcel
    - **area**: Area of the parcel
    - **zoning**: ID of the zoning
    - **geometry_latitude**: Location's latitude of the parcel
    - **geometry_longitude**: Location's longitude of the parcel

- **GET /api/parcels/{parcel_id}/**
  - Description: Retrieves details of a specific land parcel by ID.

- **PUT /api/parcels/{parcel_id}/update/**
  - Description: Updates details of a specific land parcel by ID.
  - Parameters: Same as POST endpoint.

- **DELETE /api/parcels/{parcel_id}/delete/**
  - Description: Deletes a specific land parcel by ID.

- **GET /api/parcels/nearby/**
  - Description: Finds parcels near a location within a specified distance.
  - Parameters:
    - **lat**: Latitude of the location
    - **lon**: Longitude of the location
    - **distance**: Distance in kilometers(km)

- **GET /api/parcels/area/**
  - Description: Finds parcels that has area between a specified area range (min_area, max_area).
  - Parameters:
    - **min_area**: Minimum area
    - **min_area**: Maximum area

### Delivery Endpoints

- **GET /api/delivery/**
  - Description: Retrieves a list of all delivery records.

- **POST /api/delivery/add/**
  - Description: Creates a new delivery.
  - Parameters:
    - **parcel**: ID of the parcel
    - **created_date** (optional): datetime of delivery record creation
    - **delivery_date** (optional): datetime of expected delivery
    - **delivery_status** (optional): delivery's status (allowed values: created, in_progress, delivered, failed)
    - **delivery_notes** (optional): delivery's notes

- **GET /api/delivery/{parcel_id}/**
  - Description: Retrieves details of a specific delivery by ID.

- **PUT /api/delivery/{parcel_id}/update/**
  - Description: Updates details of a specific delivery by ID.
  - Parameters:
    - **delivery_date** (optional): datetime of expected delivery
    - **delivery_status** (optional): delivery's status (allowed values: created, in_progress, delivered, failed)
    - **delivery_notes** (optional): delivery's notes

- **DELETE /api/delivery/{parcel_id}/delete/**
  - Description: Deletes a specific delivery by ID.

### Statistics Endpoints

- **GET /api/statistics/**
  - Description: Retrieves details of some statistics related with parcels and delivery.

### User Sign in Endpoints

- **GET /api/login/**
  - Description: allows authenticated users to sign in.
  - Parameters:
    - **username**: User's username
    - **password**: User's password


## Deployment <a name="deployment"></a>

### Prerequisites
- Python 3.x
- Django
- Django REST Framework
- MySQL

### Steps
1. Clone the repository to your local machine:

```bash
git clone https://github.com/HERO-EYE/land-parcel-management.git
cd land-parcel-management/Backend
```

2. Install required Python packages:

```bash
pip install -r requirements.txt
```
3. Configure the database settings in settings.py:

```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',  # For MySQL
        'NAME': 'your_database_name',
        'USER': 'your_database_user',
        'PASSWORD': 'your_database_password',
        'HOST': 'localhost',
        'PORT': '3306',
    }
}
```

4. Apply database migrations:

```bash
python manage.py makemigrations
python manage.py migrate
```

5. Run the development server:

```bash
python manage.py runserver
```

6. The API endpoints should now be accessible at `http://localhost:8000/api/`.

## Usage <a name="usage"></a>

Use tools like Postman or curl to test API endpoints manually.

### Example API requests:

#### Create a new owner:
* Method: POST
* URL: http://localhost:8000/api/owner/add/
* Body: 
    - **username**: Owner's username
    - **password**: Owner's password
    - **name**: Owner's name
    - **civil_id**: Owner's civil ID
    - **contact_phone** (optional): Owner's contact phone
    - **contact_email** (optional): Owner's contact phone

#### Retrieve all land parcels:
* Method: GET
* URL: http://localhost:8000/api/parcels/

#### Update zoning regulations:
* Method: PUT
* URL: http://localhost:8000/api/zoning/{zoning_id}/update/
* Body:
    - **zoning_type**: Type of zoning regulations
    - **regulations_details**: Details of zoning regulations

#### Delete a land parcel:
* Method: DELETE
* URL: http://localhost:8000/api/parcels/{parcel_id}/

## Demo <a name="demo"></a>

This system is deployed and hosted on this domain:
```bash
https://herodev.pythonanywhere.com/
```

### Demo API requests:

- **Note** : You must add the following header in the request headers
```Header
 Authorization: eyJ0eXAiOiJKV1oiODZWEYm*4kdgra0n!z3t3*yea!d17bd
```
  
#### Create a new owner:
* Method: POST
* URL: https://herodev.pythonanywhere.com/api/owner/
* Body:
    - **username**: Owner's username
    - **password**: Owner's password
    - **name**: Owner's name
    - **civil_id**: Owner's civil ID
    - **contact_phone** (optional): Owner's contact phone
    - **contact_email** (optional): Owner's contact phone

#### Retrieve all owners:
* Method: GET
* URL: https://herodev.pythonanywhere.com/api/app/owner/

#### Retrieve all zoning regulations:
* Method: GET
* URL: https://herodev.pythonanywhere.com/api/zoning/
  
#### Create a new land parcel:
* Method: POST
* URL: https://herodev.pythonanywhere.com/api/parcels/add/
* Body:
    - **parcel_number**: a unique number of the parcel
    - **owner**: ID of the owner
    - **city**: City of the parcel
    - **address**: Address of the parcel
    - **area**: Area of the parcel
    - **zoning**: ID of the zoning
    - **geometry_latitude**: Location's latitude of the parcel
    - **geometry_longitude**: Location's longitude of the parcel
      
#### Retrieve all land parcels:
* Method: GET
* URL: https://herodev.pythonanywhere.com/api/parcels/

## Mobile App <a name="app"></a>

A mobile application is developed for parcel lands owners to track their land parcels. Only android version is ready. 
The installation is in the following link:
```bash
https://portal.testapp.io/apps/install/0qAqjmyWNzQz4/
```

- You can use the following demo user to access the app.
  
```bash
username: user1
password: user1
```
