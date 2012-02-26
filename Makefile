#make file for httpclient

#variables
CC=gcc
CFLAGS=-c -Wall -I/usr/local/include
LDFLAGS=-L/usr/local/lib -lcurl
SOURCES=c/curlclient.c
OBJECTS=curlclient.o
EXECUTABLE=curlclient

$(EXECUTABLE):
	$(CC) $(CFLAGS) $(SOURCES)
	$(CC) $(LDFLAGS) $(OBJECTS) -o $@


#$(EXECUTABLE): $(OBJECTS)

.c .o: 
	$(CC) $(CFLAGS) $< -o $@

shared:
	$(CC) -c -Bsymbolic -fPIC $(SOURCES) -I/usr/local/include
	$(CC) -shared -o libcurlclient.so $(OBJECTS) -L/usr/local/lib -lcurl

clean:
	rm -rf *o $(EXECUTABLE)
