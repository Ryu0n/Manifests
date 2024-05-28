variable "myvar" {
	type = string
	default = "hello terraform"
}

variable "mymap" {
	type = map(string)
	default = {
		mykey = "myvalue"
	}
}

variable "mylist" {
	type = list(string)
	default = ["a", "b", "c"]
}

variable "mylist2" {
	type = list(number)
	default = [1, 2, 3]
}

variable "mylist3" {
	type = list(object({
		name = string
		age = number
	}))
	default = [
		{
			name = "Alice"
			age = 30
		},
		{
			name = "Bob"
			age = 25
		}
	]
}
