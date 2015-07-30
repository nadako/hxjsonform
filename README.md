## NOT READY YET

This is a little JSON editor generator in Haxe.

The basic idea is to pass a schema and get an editor that can display, edit and validate values based on that schema.

It doesn't use JSON-Schema as it's really meant to be used for validation and it's a bit annoying to use for editor generation.

TODO:

 * complete basic types
 * support ADT-ish choices like {?optionA:Int, ?optionB:String}
 * support selecting one of given object schemas for a single value (e.g. for base "MapItem" there can be "House", "Turret", etc.)
 * validation
 * macro schema generation from haxe types
