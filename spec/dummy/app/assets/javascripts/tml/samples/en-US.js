(function() {
  addExamples("en-US", "English", [
    {separator: true, label: "Baiscs"},

    {label: "Hello World"},
    {label: "Invite", description: "An invitation"},
    {label: "Invite", description: "Action to invite someone"},

    {separator: true, label: "Numeric Rules"},

    {label: "Number of messages: {count}", tokens: {"count": 5}},
    {label: "You have {count|| one: message, other: messages}", tokens: {"count": 5}},
    {label: "You have {count|| message, messages}", tokens: {"count": 5}},
    {label: "You have {count|| message}", tokens: {"count": 5}},
    {label: "You have {count| message}", tokens: {"count": 5}},

    {separator: true, label: "Gender Rules"},
    {label: "{user | male: He, female: She, other: He/She} likes this movie.", tokens: {user: "unknown"}},
    {label: "{user | He, She} likes this movie.", tokens: {user: "male"}},
    {label: "{user} uploaded a photo of {user | himself, herself}.", tokens: {user: {"gender": "female", "value": "Anna"}}},

    {separator: true, label: "Decorators"},

    {label: "Hello [bold: World]"},
    {label: "Hello [bold: {user}]", tokens: {"user": "Michael"}},
    {label: "Hello [bold: {user}], you have {count||message}.", tokens: {"user": "Michael", "count": 5}},
    {label: "Hello [bold: {user}], [italic: you have [bold: {count||message}]].", tokens: {"user": "Michael", "count": 1}},
    {label: "Hello [bold: {user}], [italic]you have [bold: {count||message}][/italic].", tokens: {"user": "Michael", "count": 3}},

    {separator: true, label: "Implied Tokens"},

    {label: "{user | He, She} likes this post.", tokens: {"user": {"object": {"gender": "male", "name": "Michael"}}}},
    {label: "{user | Dear} {user}", tokens: {"user": {"object": {"gender": "male", "name": "Michael"}, "attribute": "name"}}},

    {separator: true, label: "Lists"},

    {label: "{users || likes, like} this post.", tokens: {"users": [[{"gender": "male", "name": "Michael"}, {"gender": "female", "name": "Anna"}], {"attribute": "name"}]}},
    {label: "{users || likes, like} this post.", tokens: {"users": [[{"gender": "female", "name": "Anna"}], {"attribute": "name"}]}},
    {label: "{users | He likes, She likes, They like} this post.", tokens: {"users": [[{"gender": "male", "name":"Michael"}, {"gender": "female", "name":"Anna"}], {"attribute": "name"}]}},
    {label: "{users | He likes, She likes, They like} this post.", tokens: {"users": [[{"gender": "female", "name":"Anna"}], {"attribute": "name"}]}},
    {label: "{users | He likes, She likes, They like} this post.", tokens: {"users": [[{"gender": "male", "name":"Michael"}], {"attribute": "name"}]}}
  ])
})();