-- Bundesländer in Germany

select * from osm.place_polygon_nested where nest_level = 2 and admin_level <=4;

