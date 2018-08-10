#include <dlfcn.h>
#include <spawn.h>

void patch_setuid() {
	void* handle = dlopen("/usr/lib/libjailbreak.dylib", RTLD_LAZY);
	if (!handle) return;

	// Reset errors
	dlerror();
	typedef void (*fix_setuid_prt_t)(pid_t pid);
	fix_setuid_prt_t ptr = (fix_setuid_prt_t)dlsym(handle, "jb_oneshot_fix_setuid_now");
	
	const char *dlsym_error = dlerror();
	if (dlsym_error) return;

	ptr(getpid());
}

int main(int argc, char **argv, char **envp) {
	if (argc == 1) {
		fprintf(stdout, "Usage: %s [command]\n", argv[0]);
		return 0;
	}

	setuid(0);
	if (getuid() != 0) {
		patch_setuid();
		setuid(0);
	}
	if (getuid() != 0) {
		patch_setuid();
		setuid(0);
	}
	if (getuid() != 0) {
		fprintf(stderr, "setuid(0) failed\n");
		return 1;
	}

	int status;
	pid_t pid;

	const char *shc[] = {"sh", "-c"};
	const char **args = (const char **)malloc((argc + 2) * sizeof(*args));

	for (size_t i = 0; i < argc + 1; ++i) {
		args[i] = strdup(i < 2 ? shc[i] : argv[i - 1]);
	}

	posix_spawn(&pid, "/bin/sh", NULL, NULL, (char* const*)args, NULL);
	waitpid(pid, &status, 0);

	return 0;
}

// vim:ft=objc
