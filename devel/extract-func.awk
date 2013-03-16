# func_name variable will be passed from outside.

BEGIN {
	func_start = 0
	bracket = 0
}

/function +[a-zA-Z0-9]/ {
	if (length(func_name) <= 0) {
		func_start = 1
	}
	else if (match($0, func_name)) {
		func_start = 1
	}
}

/{/ {
	if (func_start == 1) {
		bracket++
	}
}

{
	if (func_start == 1) {
		print $0
	}
}

/}/ {
	if (func_start == 1) {
		bracket--
	}
	
	if (bracket == 0) {
		func_start = 0
	}
}

