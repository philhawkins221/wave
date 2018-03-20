import Vapor

let drop = try Droplet()

drop.get("hello") { req in
    return "Hello Vapor pooooopy butt"
}

try drop.run()
