/*
 * =====================================================================================
 *
 *       Filename:  snd-i2smic-rpi
 *
 *    Description:  I2S microphone kernel module
 *
 *        Version:  0.1.0
 *        Created:  2020-04-14
 *       Revision:  none
 *       Compiler:  gcc
 *
 *       Pi4 Mods:  Carter Nelson
 *    Orig Author:  Huan Truong (htruong@tnhh.net), originally written by Paul Creaser
 *
 * =====================================================================================
 */
#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/kernel.h>
#include <linux/kmod.h>
#include <linux/platform_device.h>
#include <sound/simple_card.h>
#include <linux/delay.h>
#include "snd-i2smic-rpi.h"

/*
 * modified for linux 4.1.5
 * inspired by https://github.com/msperl/spi-config
 * with thanks for https://github.com/notro/rpi-source/wiki
 * as well as Florian Meier for the rpi i2s and dma drivers
 *
 * to use a differant (simple-card compatible) codec
 * change the codec name string in two places and the
 * codec_dai name string. (see codec's source file)
 *
 *
 * N.B. playback vs capture is determined by the codec choice
 * */

static struct asoc_simple_card_info card_info;
static struct platform_device card_device;


/*
 * Dummy callback for release
 */
void device_release_callback(struct device *dev) { /*  do nothing */ };

/*
 * Setup the card info
 */
static struct asoc_simple_card_info default_card_info = {
  .card = "snd_rpi_i2s_card",       // -> snd_soc_card.name
  .name = "simple-card_codec_link", // -> snd_soc_dai_link.name
  .codec = "snd-soc-dummy",         // "dmic-codec", // -> snd_soc_dai_link.codec_name
  .platform = "not-set.sai",
  .daifmt = SND_SOC_DAIFMT_I2S | SND_SOC_DAIFMT_NB_NF | SND_SOC_DAIFMT_CBS_CFS,
  .cpu_dai = {
    .name = "not-set.sai",          // -> snd_soc_dai_link.cpu_dai_name
    .sysclk = 0
  },
  .codec_dai = {
    .name = "snd-soc-dummy-dai",    //"dmic-codec", // -> snd_soc_dai_link.codec_dai_name
    .sysclk = 0
  },
};

/*
 * Setup the card device
 */
static struct platform_device default_card_device = {
  .name = "asoc-simple-card",   //module alias
  .id = 1,
  .num_resources = 0,
  .dev = {
    .release = &device_release_callback,
    .platform_data = &default_card_info, // *HACK ALERT*
  },
};

/*
 * Callback for module initialization
 */
int i2s_mic_rpi_init(void)
{
  const char *dmaengine = "imx-sdma"; //module name
  static char *card_platform;
  int ret;

  printk(KERN_INFO "snd-i2smic-rpi: Version %s\n", SND_I2SMIC_RPI_VERSION);

  card_platform = "30010000.sai";

  printk(KERN_INFO "snd-i2smic-rpi: Setting platform to %s\n", card_platform);

  // request DMA engine module
  ret = request_module(dmaengine);
  pr_alert("request module load '%s': %d\n",dmaengine, ret);

  // update info
  card_info = default_card_info;
  card_info.platform = card_platform;
  card_info.cpu_dai.name = card_platform;

  card_device = default_card_device;
  card_device.dev.platform_data = &card_info;

  // register the card device
  ret = platform_device_register(&card_device);
  pr_alert("register platform device '%s': %d\n",card_device.name, ret);

  return 0;
}

/*
 * Callback for module exit
 */
void i2s_mic_rpi_exit(void)
{
  platform_device_unregister(&card_device);
  pr_alert("i2s mic module unloaded\n");
}

// Plumb it up
module_init(i2s_mic_rpi_init);
module_exit(i2s_mic_rpi_exit);
MODULE_DESCRIPTION("ASoC simple-card I2S Microphone");
MODULE_AUTHOR("Carter Nelson");
MODULE_LICENSE("GPL v2");