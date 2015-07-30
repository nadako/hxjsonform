enum Schema<T> {
    VString : Schema<String>;
    VStringChoice(choices:Array<String>) : Schema<String>;
    VObject(fields:Array<ObjectField>) : Schema<{}>;
}

typedef ObjectField = {
    var name:String;
    var type:Schema<Dynamic>;
}
