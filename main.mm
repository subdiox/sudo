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

	setuid(0);
	setgid(0);
	setuid(0);
	setgid(0);
}

int main(int argc, char **argv, char **envp) {
	if (argc == 1) {
		fprintf(stdout, "usage: %s [command] [args]\n", argv[0]);
		return 0;
	}

	setuid(0);
	if (getuid() != 0) {
		patch_setuid();
	}
	if (getuid() != 0 || getgid() != 0) {
		fprintf(stderr, "setuid(0) failed\n");
		return 1;
	}

	int status;
	pid_t pid;

	char *arg = (char *)malloc(sizeof(char) * (1 << 16));

	for (int i = 1; i < argc - 1; i ++) {
		strcat(arg, argv[i]);
		strcat(arg, " ");
	}
	strcat(arg, argv[argc - 1]);

	const char *args[] = {"sh", "-c", arg, NULL};
	posix_spawn(&pid, "/bin/sh", NULL, NULL, (char* const*)args, NULL);

	waitpid(pid, &status, 0);

	return 0;
}

// vim:ft=objc
