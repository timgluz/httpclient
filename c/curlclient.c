#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <curl/curl.h>


struct MemoryStruct {
    char *memory;
    size_t size;
};

typedef struct {
    unsigned int  success;
    long status_code;
    char *url;
    char *content_type;
    char *content;
    char *header;
    char *error_msg;
} httpresponse_t;



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

    return realsize;
}

unsigned int _get(httpresponse_t *response, char* url, 
        struct curl_slist *headers, long timeout){
    /*
     *Makes HTTP GET request to server and returns 
     */
    CURL *handle;
    CURLcode res_code = -1;
    struct MemoryStruct chunk;
    struct MemoryStruct header_chunk; //holds response header

    chunk.memory = malloc(1); //will be grown as needed by the realloc above
    chunk.size = 0;
    header_chunk.memory = malloc(1);
    header_chunk.size =  0;

    handle = curl_easy_init();
    if(!handle){
        response->success = 0;
        strncpy(response->error_msg, "Cant init cURL handler.\0", 24);
        return 1;
    }
    
    //set settings
    curl_easy_setopt(handle, CURLOPT_URL, url);
    curl_easy_setopt(handle, CURLOPT_HTTPHEADER, headers);
    curl_easy_setopt(handle, CURLOPT_TIMEOUT, timeout);
    curl_easy_setopt(handle, CURLOPT_HEADER, 0);
    //set callbacks 
    curl_easy_setopt(handle, CURLOPT_WRITEFUNCTION, WriteMemoryCallback);
    curl_easy_setopt(handle, CURLOPT_WRITEDATA, (void *) &chunk);
    curl_easy_setopt(handle, CURLOPT_WRITEHEADER, (void *) &header_chunk);
    curl_easy_setopt(handle, CURLOPT_NOPROGRESS, 1);
    res_code = curl_easy_perform(handle);
    
    
    //if reading URL was Unsuccessful
    if(res_code != CURLE_OK){
        response->success = 0;
        response->status_code = res_code;
        strncpy(response->error_msg, "Unsuccessful reading\0", 21);
        return 1;
    }
    else{
        //build response

        response->success = 1;
        //curl_easy_getinfo(handle, CURLINFO_RESPONSE_CODE, &tmp);
        //curl_easy_getinfo(handle, CURLINFO_CONTENT_TYPE, &response->content_type);
        response->content = malloc(sizeof(char) * chunk.size);
        memcpy(response->content,(char *) chunk.memory, chunk.size);

        response->header = malloc(sizeof(char) * header_chunk.size);
        memcpy(response->header, (char *) header_chunk.memory, header_chunk.size);
    }

    //free memory 
    free(chunk.memory);
    free(header_chunk.memory);
    curl_easy_cleanup(handle);

    return 0;
    //return (char *) chunk.memory;
}

//#TODO: FIND GOODWAY to return httpresponse value
void j_get(char* url, char* csv_headers, long timeout){
    /*
     *Its wrapper function for JULIA with simplistic interface and datatypes.
     * 
     */
    char *response;
    unsigned int failed = 2;
    httpresponse_t result;
    printf("BP1");
    struct curl_slist *http_headers = NULL;
    char  *pch;
    //tokenize string csv_header and splitted values into http_headers
    printf("Tokenizer");
    pch = strtok(csv_headers, "!");
    while(pch !=NULL){
        printf("%s\n", pch);
        curl_slist_append(http_headers, (const char *) pch); 
        pch = strtok(NULL, "!");
    }

    printf("running julia wrapper");
    failed = _get(&result, url, http_headers, timeout);
    if(!failed){
        //if request has has success, then build encoded string
        response = (char *) malloc(sizeof(char) * strlen(result.content));
        strcpy(response, result.content);
    }
    else{
        response = (char *) malloc(sizeof(char) * 8);
        strcpy(response, "failed.\0");
    }
   // return response;
}

int test_get(void){
    httpresponse_t result;
    struct curl_slist *headers = NULL;
    long timeout = 30;
    unsigned int failed =  1;
    
    headers = curl_slist_append(headers, 
            "User-Agent: Mozilla/5.0 (compatible; MSIE 9.0; HTTPCLIENT-JULIA)");
    headers = curl_slist_append(headers, "Accept-Charset: utf-8");
    headers = curl_slist_append(headers, "Content-Type: text/plain"); 

    failed = _get(&result, "http://httpbin.org/ip", headers, timeout);
    if(!failed){
        printf("Success: %d\n", result.success);
        printf("Headers:\n%s\n", result.header);
        //printf("Content:\n%s\n", result.content);
    }
    else{
        printf("Failed request.");
        return 1;
    }

    free(result.header);
    free(result.content);

    return 0;
}


int main(void){

    char url[] = "http://httpbin.org/ip\0";
    char headers[] = "Content-Type:text/csv!Accept-Charset: utf-8\0";

    printf("TEST function http_get method:");
    j_get(url, headers, 45);

    //test_get();
    return 0;
}

