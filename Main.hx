import js.Browser.document;
import js.Browser.window;

import Schema;

class Main {
    static function main() {
        var schema = VObject([
            {
                name: "name",
                type: VString
            },
            {
                name: "type",
                type: VStringChoice([
                    "hq",
                    "post",
                    "turret"
                ])
            },
            {
                name: "coords",
                type: VObject([
                    {name: "x", type: VString},
                    {name: "y", type: VString},
                ])
            }
        ]);
        window.onload = function() {
            var container = document.getElementById("container");
            var editor = Editor.create("root", schema);
            editor.setValue({
                name: "House",
                type: "post",
                coords: {x: 10, y: 15},
            });
            container.appendChild(editor.root);

            document.getElementById("submit").onclick = function() {
                trace(editor.getValue());
            };
        };
    }

}
