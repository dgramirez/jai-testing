
build :: ()
{
	options := get_build_options();
	args    := options.compile_time_command_line;

	defer set_build_options_dc(.{do_output=false});

	build_debug         := false;
	build_release       := false;
	build_debug_release := false;
	for arg: args {
		if arg == {
			case "debug";
				if !build_debug {
					build_program(.DEBUG);
				}
				build_debug = true;
			case "release";
				if !build_release {
					build_program(.VERY_OPTIMIZED, false);
				}
				build_release = true;
			case "debug-release";
				if !build_debug_release {
					build_program(.VERY_OPTIMIZED);
				}
				build_debug_release = true;
			case;
				compiler_report(tprint("Command-Line argument #%, '%' is invalid.\n", it_index+1, arg));
				compiler_report(tprint("Valid: debug, release, debug-release\n"));
		}
	}

	print("\n");
	if !(build_debug || build_release || build_debug_release) {
		print("Please add parameter(s) to the build.jai:\n");
		print("\tdebug\n");
		print("\trelease\n");
		print("\tdebug-release\n");
		print("\nex:\n");
		print("\tjai build.jai - debug\n");
		print("\tjai build.jai - release\n");
		print("\tjai build.jai - debug-release\n");
		print("\tjai build.jai - debug release debug-release\n");
	}
}

build_program :: (optimization: Optimization_Type , preserve_debug := true)
{
	w           := compiler_create_workspace();
	options     := get_build_options();
	output_path := "";
	set_optimization(*options, optimization, preserve_debug);

	if (preserve_debug) {
		if (optimization == .DEBUG)
			output_path = tprint("%/out/debug", #filepath);
		else
			output_path = tprint("%/out/debug-release", #filepath);
	}
	else
		output_path = tprint("%/out/release", #filepath);

	make_directory_if_it_does_not_exist(output_path, true);

	options.output_executable_name = "HelloWorld";
	options.output_path = output_path;
	set_build_options(options, w);

	compiler_begin_intercept(w);
	add_build_file(tprint("%/src/main.jai", #filepath), w);

	while true {
		message := compiler_wait_for_message();
		if message.kind == .COMPLETE
			break;
	}

	compiler_end_intercept(w);
}

#run build();
#import "Basic";
#import "Compiler";
#import "Process";
#import "File_Utilities";
#import "File";

