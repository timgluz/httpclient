#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <curl/curl.h>


struct MemoryStruct {
    char *memory;
    size_t size;
};

static size_t WriteMemoryCallback(void *contents, size_t size, size_t nmemb, void *userp){
    //---------------------------
    size_t realsize = size * nmemb;
    struct MemoryStruct *mem = (struct MemoryStruct *) userp;

    mem->memory = realloc(mem->memory, mem->size + realsize +1);
    if(mem->memory == NULL){
        //if we run out of Memory
        printf("Not enough memory to put retrieved object into memory.");
        exit(EXIT_FAILURE);
    }
    
    memcpy(&(mem->memory[mem->size]), contents, realsize);
    mem->size += realsize;
    mem->memory[mem->size] = 0;

}

char*  get(char* url){
    CURL *handle;
    CURLcode res_code = -1;
    struct MemoryStruct chunk;
    //char* response;
    chunk.memory = malloc(1); //will be grown as needed by the realloc above
    chunk.size = 0;

    handle = curl_easy_init();
    if(handle){
        curl_easy_setopt(handle, CURLOPT_URL, url);
        curl_easy_setopt(handle, CURLOPT_WRITEFUNCTION, WriteMemoryCallback);
        curl_easy_setopt(handle, CURLOPT_WRITEDATA, (void *) &chunk);
        res_code = curl_easy_perform(handle);
    }

    /*memcpy(response, (char *) chunk.memory, chunk.size+1);
    if(chunk.memory){
        free(chunk.memory);
    }*/
    curl_easy_cleanup(handle);
    return (char *) chunk.memory;

}


int main(void){
    char* result;

    result = get("http://httpbin.org/ip");
    printf("result:\n%s\n",result);
    return 0;
}

