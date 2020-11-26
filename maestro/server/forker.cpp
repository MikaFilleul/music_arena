#include <string>
#include <cstring>

#include <sys/types.h>
#include <sys/wait.h>

#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

using namespace std;

int main(int argc, char **argv)
{

	if (argc != 6) {
		fprintf(stderr, "Error: %d arguments expected (received %d)\n",
			6, argc);
		return EXIT_FAILURE;
	}

	pid_t c_pid, pid;
	int status;

	c_pid = fork();		//duplicate

	if (c_pid == 0) {

		//child
		pid = getpid();

		fprintf(stdout, "Server %s intialized: pid is %d \n", argv[2],
			pid);

		char serverId[32] = "--id=";
		strcat(serverId, argv[2]);

		char serverPw[32] = "--pw=";
		strcat(serverPw, argv[3]);

		char serverIp[32] = "--ip=";
		strcat(serverIp, argv[4]);

		char serverPort[32] = "--port=";
		strcat(serverPort, argv[5]);

		char *serverArgs[] =
		    { "../Godot_v3.2.1-stable_linux_server.64", "--main-pack",
			argv[1], serverId, serverPw, serverIp, serverPort, NULL
		};

		// TODO: CHECK THE RETURN OF EXECVP
		execvp(serverArgs[0], serverArgs);

		return EXIT_SUCCESS;
	}

	else if (c_pid > 0) {

		//parent waiting for child to terminate
		pid = wait(&status);

		if (WIFEXITED(status)) {
			fprintf(stdout,
				"Forker: Server %s process exited with status: %d\n",
				argv[1], WEXITSTATUS(status));
		}

		return 42;
	}

	else {

		// c_pid is negative ?!
		perror
		    ("Forker failed, the reality is collapsing on itself !!!");
		return EXIT_FAILURE;
	}
}
