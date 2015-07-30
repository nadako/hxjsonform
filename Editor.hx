import js.Browser.console;
import js.Browser.document;
import js.html.Element;
import js.html.InputElement;

import Schema;

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
    var choices:Array<String>;
    var elems:Map<String,InputElement>;

    public function new(id:String, choices:Array<String>) {
        this.choices = choices;
        this.elems = new Map();
        var div = document.createDivElement();
        div.id = id;
        super(div);

        for (choice in choices) {
            var row = document.createLabelElement();

            var radio = document.createInputElement();
            radio.type = "radio";
            radio.name = id;
            elems[choice] = radio;
            row.appendChild(radio);

            var label = document.createTextNode(choice);
            row.appendChild(label);

            div.appendChild(row);
        }
    }

    public override function setValue(value:String):Void {
        for (choice in elems.keys()) {
            elems[choice].checked = (choice == value);
        }
    }

    public override function getValue():String {
        for (choice in elems.keys()) {
            if (elems[choice].checked)
                return choice;
        }
        console.warn("No value checked");
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
