# MobilityDBInternship2024
This repository contains the work done by Alice Lombard and Raphaël Dubuget during an internship at the ULB in the 2024 summer.

## Introduction
MobilityDB is a temporal extension for PostgreSQL that adds support for managing temporal and spatiotemporal data. The goal of this internship is to use MobilityDB with STAR's data, which is a dataset of the public transportation system in the city of Rennes. The data is in many forms, from CSV to GTFS and GBFS. The goal is to convert this data into a format that can be used by MobilityDB, and then use MobilityDB to perform some queries on the data. We also want to visualize the data, and to do so we will use QGIS. We also used other sources of information, such as OpenStreetMap.

## Workshop Summary
The workshop was divided into 5 parts:
### 1. Introduction to MobilityDB - First Steps
In this part, we learned about MobilityDB, its main features, and how to install it. We also learned how to create a database and some points, lines, and temporal geometric points, using PostgreSQL, PostGIS, and MobilityDB.
### 2. Importing STAR's data - Managing Bus Trajectories
In this part, we learned how to import STAR's data into MobilityDB. We used some CSV data to create a table with the trajectories of the buses in Rennes.
### 3. Animating GPX data
In this part, we learned how to animate the data using QGIS. We used the data from OpenStreetMap to create an animation of the hiking track (a GPX file) using the Move plugin in QGIS.
### 4. Managing GTFS data
In this part, we learned how to manage GTFS data using MobilityDB. We had the GTFS data from STAR, and used gtfs-via-postgresql to create a table with the stops and the trips of the public transportation system in Rennes.
### 5. Managing JSON data - GBFS data
In this part, we learned how to manage JSON data using MobilityDB. In this case, we had the GBFS data from STAR.