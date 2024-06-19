SELECT *
FROM pg_catalog.pg_tables
WHERE schemaname != 'pg_catalog' AND 
    schemaname != 'information_schema';

Select * from agency limit 30;
-- same as in V1

Select * from calendar limit 30;
-- 0->not_available
-- 1->available

Select * from calendar_dates limit 30;
-- 2->removed and 1->added

Select * from feed_info limit 30;
-- +default_lang (null)

Select * from routes limit 30;
-- agency_id: text instead of int
-- route_type: route_type_val instead of int

Select * from shapes limit 30;
-- +id: int (order of the shapes)
-- shape_pt_loc: geography (instead of shape_pt_lat and shape_pt_long: double precision)
-- shape_dist_traveled: real instead of double precision. It is truncated contrarily to the V1 which is more precise.

Select * from stops limit 30;
-- stop_loc: geography (instead of stop_lat and stop_long: double precision)
-- +level_id: text (null)
-- location_type: location_type_val (already filled with "station", etc... value) (instead of int 0,1,2,3,4)
-- wheelchair_borading: wheelchair_boarding_val (accessible instead of int 1)
-- -stopgeom: geometry (null)

Select * from stop_times where shape_dist_traveled is not null;
-- +stop_sequence_consec: int
-- pickup_type and drop_off_type: pickup_drop_off_type (already filled with "regular", etc... value) (instead of int 0,1,2,3)
-- shape_dist_traveled: real instead of double precision. It is NOT truncated.
-- timepoint: timepoint_v ("exact" instead of int 1)

Select * from trips limit 30;
-- wheelchair_accessible: wheelchair_accessibility ("accessible" instead of int 0,1)
-- bikes_allowed: bikes_allowance ("unknown" instead of int 0,1)

Select * from frequencies limit 30;
-- does not exists in V1

Select * from spatial_ref_sys limit 30;
-- does not exists in V1