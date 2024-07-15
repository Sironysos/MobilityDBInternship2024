# MobilityDBInternship2024
This repository contains the work done by Alice Lombard and Raphaël Dubuget during the MobilityDB Internship 2024 at the ULB.

## Introduction
MobilityDB is a temporal extension for PostgreSQL that adds support for managing temporal and spatiotemporal data. The goal of this internship is to use mobilityDB with STAR's data, which is a dataset of the public transportation system in the city of Rennes. The data is in many forms, from CSV to GTFS and GTFS realtime. The goal is to convert this data into a format that can be used by MobilityDB, and then use MobilityDB to perform some queries on the data. We also want to visualize the data, and to do so we will use Grafana and QGIS.

## Workshop Summary
The workshop was divided into 7 parts:
### 1. Introduction to MobilityDB - First Steps
In this part, we learned about MobilityDB, its main features, and how to install it. We also learned how to create a database and some points, lines, and temporal geometric points, using PostgreSQL, PostGIS, and MobilityDB.
### 2. Importing STAR's data - Managing Bus Trajectories
In this part, we learned how to import STAR's data into MobilityDB. We used some CSV data to create a table with the stops of the public transportation system in Rennes. We then used the GTFS data to create a table with the trips of the public transportation system in Rennes. 
### 3. Visualizing STAR's data - Grafana
In this part, we learned how to visualize the data using Grafana. We used the data from the previous part to create a dashboard with the stops and the trips of the public transportation system in Rennes.
### 4. Animating STAR's data - Hiking in QGIS
In this part, we learned how to animate the data using QGIS. We used the data from OpenStreetMap to create an animation of the hiking track using Move plugin in QGIS.
### 5. Managing GTFS data
In this part, we learned how to manage GTFS data using MobilityDB. We had the GTFS data from STAR, and used gtfs-via-postgresql to create a table with the stops and the trips of the public transportation system in Rennes.
### 6. Managing GTFS realtime data
In this part, we learned how to manage GTFS realtime data using MobilityDB. We had the GTFS realtime data from STAR, and then we were lost in the sea because we don't understand it.
### 7. Managing JSON data
In this part, we learned how to manage JSON data using MobilityDB. We had the JSON data from Google Maps.