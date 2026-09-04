.pragma library

function valueType(value) {
    if (value === null)
        return "null";
    if (Array.isArray(value))
        return "array";
    if (typeof value === "number" && Number.isInteger(value))
        return "integer";
    return typeof value;
}

function matchesType(value, expected) {
    if (expected === "number")
        return typeof value === "number" && Number.isFinite(value);
    if (expected === "integer")
        return typeof value === "number" && Number.isInteger(value);
    if (expected === "object")
        return value !== null && typeof value === "object" && !Array.isArray(value);
    if (expected === "array")
        return Array.isArray(value);
    if (expected === "null")
        return value === null;
    return typeof value === expected;
}

function deepEqual(left, right) {
    if (left === right)
        return true;
    if (typeof left !== typeof right || left === null || right === null)
        return false;
    if (Array.isArray(left)) {
        if (!Array.isArray(right) || left.length !== right.length)
            return false;
        return left.every((value, index) => deepEqual(value, right[index]));
    }
    if (typeof left === "object") {
        const leftKeys = Object.keys(left);
        const rightKeys = Object.keys(right);
        return leftKeys.length === rightKeys.length
            && leftKeys.every(key => Object.prototype.hasOwnProperty.call(right, key) && deepEqual(left[key], right[key]));
    }
    return false;
}

function addError(errors, path, keyword, message) {
    errors.push({ path: path, keyword: keyword, message: message });
}

function validateNode(value, schema, path, errors) {
    if (schema === true || schema === undefined || schema === null)
        return;
    if (schema === false) {
        addError(errors, path, "schema", "value is not allowed");
        return;
    }

    if (schema.type !== undefined) {
        const types = Array.isArray(schema.type) ? schema.type : [schema.type];
        if (!types.some(type => matchesType(value, type))) {
            addError(errors, path, "type", "expected " + types.join(" or ") + ", got " + valueType(value));
            return;
        }
    }

    if (schema.const !== undefined && !deepEqual(value, schema.const))
        addError(errors, path, "const", "value does not match the required constant");

    if (schema.enum !== undefined && !schema.enum.some(candidate => deepEqual(value, candidate)))
        addError(errors, path, "enum", "value is not in the allowed set");

    if (typeof value === "number") {
        if (schema.minimum !== undefined && value < schema.minimum)
            addError(errors, path, "minimum", "value must be at least " + schema.minimum);
        if (schema.maximum !== undefined && value > schema.maximum)
            addError(errors, path, "maximum", "value must be at most " + schema.maximum);
    }

    if (typeof value === "string") {
        if (schema.minLength !== undefined && value.length < schema.minLength)
            addError(errors, path, "minLength", "string must contain at least " + schema.minLength + " characters");
        if (schema.maxLength !== undefined && value.length > schema.maxLength)
            addError(errors, path, "maxLength", "string must contain at most " + schema.maxLength + " characters");
        if (schema.pattern !== undefined && !(new RegExp(schema.pattern)).test(value))
            addError(errors, path, "pattern", "string does not match the required pattern");
    }

    if (Array.isArray(value)) {
        if (schema.minItems !== undefined && value.length < schema.minItems)
            addError(errors, path, "minItems", "array must contain at least " + schema.minItems + " items");
        if (schema.maxItems !== undefined && value.length > schema.maxItems)
            addError(errors, path, "maxItems", "array must contain at most " + schema.maxItems + " items");
        if (schema.items !== undefined)
            value.forEach((item, index) => validateNode(item, schema.items, path + "[" + index + "]", errors));
    }

    if (value !== null && typeof value === "object" && !Array.isArray(value)) {
        const properties = schema.properties ?? ({});
        const required = schema.required ?? [];

        required.forEach(key => {
            if (!Object.prototype.hasOwnProperty.call(value, key))
                addError(errors, path + "." + key, "required", "required property is missing");
        });

        Object.keys(value).forEach(key => {
            if (Object.prototype.hasOwnProperty.call(properties, key)) {
                validateNode(value[key], properties[key], path + "." + key, errors);
            } else if (schema.additionalProperties === false) {
                addError(errors, path + "." + key, "additionalProperties", "property is not allowed");
            } else if (typeof schema.additionalProperties === "object") {
                validateNode(value[key], schema.additionalProperties, path + "." + key, errors);
            }
        });
    }
}

function validate(value, schema) {
    const errors = [];
    validateNode(value, schema, "$", errors);
    return { valid: errors.length === 0, errors: errors };
}
