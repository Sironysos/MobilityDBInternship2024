from google.transit import gtfs_realtime_pb2
import requests

IN = "https://dati.comune.roma.it/catalog/dataset/a7dadb4a-66ae-4eff-8ded-a102064702ba/resource/d2b123d6-8d2d-4dee-9792-f535df3dc166/download/rome_vehicle_positions.pb"

def get_feed(address):
    feed = gtfs_realtime_pb2.FeedMessage()
    response = requests.get(address)
    feed.ParseFromString(response.content)
    return feed

def parse_feed(f):
    header = "trip_id,route_id,direction_id,start_time,start_date,vehicle_id,vehicle_label,latitude,longitude,odometer,current_stop_sequence,stop_id,current_status,timestamp"
    res = []
    for e in f.entity:
        v = e.vehicle.vehicle
        t = e.vehicle.trip
        p = e.vehicle.position
        # print(v)
        line = [t.trip_id, t.route_id, t.direction_id, t.start_time, t.start_date,
                v.id,v.label,
                p.latitude,p.longitude,p.odometer,
                e.vehicle.current_stop_sequence,e.vehicle.stop_id,
                e.vehicle.current_status,e.vehicle.timestamp]
        line = list(map(str,line))
        # if t.trip_id == 
        print(",".join(line))


# Problems: how do I map positions to see if I visited a stop ?

if __name__ == "__main__":
    parse_feed(get_feed(IN))

