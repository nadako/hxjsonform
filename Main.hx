import js.Browser.console;
import js.Browser.window;
import js.Browser.document;
import js.html.Element;
import js.html.InputElement;

enum Schema<T> {
    VString : Schema<String>;
    VStringChoice(choices:Array<String>) : Schema<String>;
    VObject(fields:Array<ObjectField>) : Schema<{}>;
}

typedef ObjectField = {
    var name:String;
    var type:Schema<Dynamic>;
}

class Editor<T> {
    public var root(default,null):Element;

    function new(root:Element) {
        this.root = root;
    }

    public function setValue(value:T):Void throw "not implemented";
    public function getValue():T throw "not implemented";

    public static function create<T>(id:String, schema:Schema<T>):Editor<T> {
        return switch (schema) {
            case VString:
                new StringEditor(id);
            case VObject(fields):
                new ObjectEditor(id, fields);
            case VStringChoice(choices):
                new StringChoiceEditor(id, choices);
        }
    }
}

class StringEditor extends Editor<String> {
    var input:InputElement;

    public function new(id:String) {
        input = document.createInputElement();
        input.id = id;
        input.type = "text";
        super(input);
    }

    public override function setValue(value:String):Void {
        input.value = value;
    }

    public override function getValue():String {
        return input.value;
    }
}

class StringChoiceEditor extends Editor<String> {
    var input:InputElement;
    var radioName:String;
    var choices:Array<String>;

    public function new(id:String, choices:Array<String>) {
        this.choices = choices;
        var div = document.createDivElement();
        div.id = id;
        super(div);

        radioName = id;
        for (index in 0...choices.length) {
            var row = document.createLabelElement();

            var radio = document.createInputElement();
            radio.type = "radio";
            radio.name = radioName;
            radio.setAttribute("idx", Std.string(index));
            row.appendChild(radio);

            var label = document.createTextNode(choices[index]);
            row.appendChild(label);

            div.appendChild(row);
        }
    }

    public override function setValue(value:String):Void {
        var index = Std.string(choices.indexOf(value));
        for (elem in document.getElementsByName(radioName)) {
            var radio:InputElement = cast elem;
            var radioIndex = radio.getAttribute("idx");
            radio.checked = radioIndex == index;
        }
    }

    public override function getValue():String {
        for (elem in document.getElementsByName(radioName)) {
            var radio:InputElement = cast elem;
            if (radio.checked) {
                var idx = Std.parseInt(radio.getAttribute("idx"));
                return choices[idx];
            }
        }
        console.warn("No value checked for " + radioName);
        return null;
    }
}
class ObjectEditor extends Editor<{}> {
    var editors:Map<String,Editor<Dynamic>>;

    public function new(id:String, fields:Array<ObjectField>) {
        var div = document.createDivElement();
        div.id = id;
        super(div);
        editors = new Map();
        for (field in fields) {
            var row = document.createDivElement();
            div.appendChild(row);

            var editorId = id + "-" + field.name;

            var label = document.createLabelElement();
            label.innerText = field.name;
            label.setAttribute("for", editorId);
            row.appendChild(label);

            var editor = Editor.create(editorId, field.type);
            row.appendChild(editor.root);
            editors[field.name] = editor;
        }
    }

    public override function setValue(value:{}):Void {
        for (field in Reflect.fields(value)) {
            var editor = editors[field];
            if (editor == null) {
                console.warn("No editor for field " + field);
                continue;
            }
            editor.setValue(Reflect.field(value, field));
        }
    }

    public override function getValue():{} {
        var result = {};
        for (field in editors.keys()) {
            var value = editors[field].getValue();
            Reflect.setField(result, field, value);
        }
        return result;
    }
}

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
                coords: {x: 10, y: 15},
            });
            container.appendChild(editor.root);

            document.getElementById("submit").onclick = function() {
                trace(editor.getValue());
            };
        };
    }

}
