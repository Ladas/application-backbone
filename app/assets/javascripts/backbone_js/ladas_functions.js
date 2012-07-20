function is_hash(object) {
//    console.log(Object.prototype.toString.call(object))
    return object && (Object.prototype.toString.call(object) == '[object Object]');
}

function is_array(object) {
//    console.log(Object.prototype.toString.call(object))
    return object && (Object.prototype.toString.call(object) == '[object Array]');
}

function is_string(object) {
    return object && (Object.prototype.toString.call(object) == '[object String]');
}