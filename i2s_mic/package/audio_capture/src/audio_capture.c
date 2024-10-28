#include <stdio.h>
#include <stdlib.h>
#include <alsa/asoundlib.h>
#include <unistd.h>

int main() {
    fprintf(stderr, "zxcv");

    const char *device = "dmic_sv";  // Device name
    snd_pcm_t *handle;
    snd_pcm_hw_params_t *params;
    int err;
    int dir;
    unsigned int rate = 32000;       // Sampling rate
    snd_pcm_uframes_t frames = 64;  // Period size (buffer size)
    int channels = 2;                // Stereo
    snd_pcm_format_t format = SND_PCM_FORMAT_S32_LE; // Sample format

    // Open PCM device for capture (non-blocking)
    err = snd_pcm_open(&handle, device, SND_PCM_STREAM_CAPTURE, SND_PCM_NONBLOCK);
    if (err < 0) {
        fprintf(stderr, "Unable to open PCM device: %s\n", snd_strerror(err));
        return 1;
    }

    // Allocate hardware parameters object
    snd_pcm_hw_params_malloc(&params);
    snd_pcm_hw_params_any(handle, params);

    // Set hardware parameters
    snd_pcm_hw_params_set_access(handle, params, SND_PCM_ACCESS_RW_INTERLEAVED);
    snd_pcm_hw_params_set_format(handle, params, format);
    snd_pcm_hw_params_set_channels(handle, params, channels);
    snd_pcm_hw_params_set_rate_near(handle, params, &rate, &dir);
    snd_pcm_hw_params_set_period_size_near(handle, params, &frames, &dir);

    // Write parameters to the driver
    err = snd_pcm_hw_params(handle, params);
    if (err < 0) {
        fprintf(stderr, "Unable to set hardware parameters: %s\n", snd_strerror(err));
        snd_pcm_close(handle);
        return 1;
    }

    // Allocate buffer for audio data
    int buffer_size = frames * channels * 4; // 4 bytes per frame for S32_LE format
    char *buffer = (char *)malloc(buffer_size);

    // Capture loop
    while (1) {
        // Read data from PCM device
        err = snd_pcm_readi(handle, buffer, frames);
        if (err == -EAGAIN) {
            // Non-blocking mode; try again later
            //usleep(1000); // Sleep for 1 ms
            continue;
        } else if (err == -EPIPE) {
            fprintf(stderr, "Buffer overrun/underrun occurred\n");
            snd_pcm_prepare(handle); // Clear overrun error
        } else if (err < 0) {
            fprintf(stderr, "Read error: %s\n", snd_strerror(err));
        } else {
            // Process or store the audio data in `buffer`
            FILE *output_file = fopen("/dev/shm/audio_capture.raw", "ab");
            if (output_file == NULL) {
                fprintf(stderr, "Unable to open output file\n");
                break;
            }
            fwrite(buffer, 1, buffer_size, output_file);
            fclose(output_file);
            // Placeholder for further data processing
        }
    }

    // Cleanup
    free(buffer);
    snd_pcm_close(handle);
    return 0;
}
