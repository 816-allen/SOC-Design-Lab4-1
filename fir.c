#include "fir.h"

void __attribute__ ( ( section ( ".mprjram" ) ) ) initfir() {
    for(int i=0;i<N;i++){
        inputbuffer[i] = 0;
        outputsignal[i] = 0;
    }
}

int* __attribute__ ( ( section ( ".mprjram" ) ) ) fir(){
    initfir();
    for(int data_idx=0;data_idx<N;data_idx++){
        int acc = 0;
        for(int i=N-1;i>0;i--){
            inputbuffer[i] = inputbuffer[i-1];
        }
        inputbuffer[0] = inputsignal[data_idx];
        for(int i=0;i<N;i++){
            acc += taps[i] * inputbuffer[i];
        }
        outputsignal[data_idx] = acc;
    }
    return outputsignal;
}
