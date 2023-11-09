# feltr (development)

* Add support for `fill_color`, `stroke_color`, and `webhook_url` parameters (2023-11-09) to `create_felt_layer()`.
* Add `update_felt_layer()` function (2023-11-09).

# feltr 0.1.2

* Add `read_felt_layers()`, `create_felt_map()`, and `delete_felt_map()` functions and `get_felt_map()` function.
* Add support for `basemap` and `layer_urls` parameter to `create_felt_map()` function.
* Remove the `url` parameter and add support for passing URLs (2023-07-13) or named lists (2023-07-19) to the `map_id` parameter.
* Add `get_felt_comments()` function (2023-07-13).
* Add `get_felt_style()` and `update_felt_style()` functions (2023-07-13).
* Add support for file uploads (2023-07-14) and `sf` or `sfc` object inputs (2023-07-19) to `create_felt_layer()`.
* Drop `{settoken}` from Imports (2023-09-26) in favor of standalone imports with similar functions.

# feltr 0.1.1 (2023-06-30)

* Add `read_felt_map()`, `create_felt_map()`, and `delete_felt_map()` functions.

# feltr 0.1.0 (2023-04-24)

* Initial release with `read_felt()`, `get_felt_data()`, and `read_felt_raster()`.
