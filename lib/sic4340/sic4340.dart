enum AVG {
  N_SAMPLES_1,
  N_SAMPLES_2,
  N_SAMPLES_4,
  N_SAMPLES_8,
  N_SAMPLES_16,
  N_SAMPLES_32,
  N_SAMPLES_64,
  N_SAMPLES_128
}

enum SIGN { UNSIGNED, SIGNED }

enum NBit {
  OSR_32_BIT_5,
  OSR_64_BIT_7,
  OSR_128_BIT_8,
  OSR_256_BIT_9,
  OSR_512_BIT_10,
  OSR_1024_BIT_10,
  OSR_2048_BIT_10,
  OSR_4096_BIT_10
}

enum AutoConvPeriod {
  MS_50,
  MS_100,
  MS_200,
  MS_500,
  SEC_1,
  SEC_2,
  SEC_5,
  SEC_10
}

enum AutoResp { INSTANT, HOLD }

enum ConvMode { SINGLE, SINGLE_, CONTINUOUS, AUTO }

enum EN { DISABLE, ENABLE }

enum LPF { ANTI_ALIASING, KHz_1250, KHz_623, KHz_325 }

enum MODE { DIFFERENTIAL, SINGLE }

enum CHANNEL { S0, S1, S2, NC }

enum DC { PULSE, CONSTANT }

enum STEP { uA_1, uA_8 }

enum T_CMP {
  ns_2360,
  ns_2655,
  ns_2950,
  ns_3245,
  ns_1180,
  ns_1475,
  ns_1770,
  ns_2065
}

class SIC4340Config {
  static const int ADC_DIVIDER_REG = 0x04;
  static const int ADC_PRESCALER_REG = 0x05;
  static const int ADC_SAMPLE_DELAY_REG = 0x06;
  static const int ADC_NWAIT_REG = 0x07;
  static const int ADC_BIT_CONFIG_REG = 0x08;
  static const int ADC_MODE_CONFIG_REG = 0x09;
  static const int ADC_BUF_CONFIG_REG = 0x0A;
  static const int ADC_CH_CONFIG_REG = 0x0B;
  static const int ISEN_CONFIG_REG = 0x0C;
  static const int ISEN_VALUE_REG = 0x0D;
  static const int VLM_VALUE_REG = 0x0E;
  static const int VDD_CONFIG_REG = 0x13;
  static const int SENSOR_CONFIG_REG = 0x18;
  static const int GAP_CMPEN_REG = 0x1A;

  int adcDivider = 143;
  int adcPrescaler = 0;
  int sampleDelay = 160;
  AVG adcAvg = AVG.N_SAMPLES_4;
  SIGN adcSign = SIGN.SIGNED;
  NBit adcNBit = NBit.OSR_1024_BIT_10;
  AutoConvPeriod adcAutoConvPeriod = AutoConvPeriod.MS_100;
  AutoResp adcAutoResp = AutoResp.HOLD;
  ConvMode adcConvMode = ConvMode.AUTO;
  EN adcBuffer = EN.ENABLE;
  LPF adcLPF = LPF.KHz_1250;
  MODE adcMode = MODE.SINGLE;
  CHANNEL adcNegChannel = CHANNEL.NC;
  CHANNEL adcPosChannel = CHANNEL.S1;
  CHANNEL isenChannel = CHANNEL.NC;
  DC isenDC = DC.CONSTANT;
  EN isenVLM = EN.DISABLE;
  STEP isenRNG = STEP.uA_8;
  int isenValue = 0;
  int vlmValue = 255;
  EN vdd = EN.ENABLE;
  EN cmpenEN = EN.DISABLE;
  T_CMP cmpenTime = T_CMP.ns_2360;

  List<String> getConfigCommands() {
    List<String> cmds = [];
    var addr = ADC_DIVIDER_REG.toRadixString(16).toUpperCase().padLeft(2, '0');
    var data =
        (adcDivider & 0xFF).toRadixString(16).toUpperCase().padLeft(2, '0');
    cmds.add("B6" + addr + data);
    addr = ADC_PRESCALER_REG.toRadixString(16).toUpperCase().padLeft(2, '0');
    data =
        (adcPrescaler & 0x07).toRadixString(16).toUpperCase().padLeft(2, '0');
    cmds.add("B6" + addr + data);
    addr = ADC_SAMPLE_DELAY_REG.toRadixString(16).toUpperCase().padLeft(2, '0');
    data = (sampleDelay & 0xFF).toRadixString(16).toUpperCase().padLeft(2, '0');
    cmds.add("B6" + addr + data);
    addr = ADC_NWAIT_REG.toRadixString(16).toUpperCase().padLeft(2, '0');
    data = (0x80).toRadixString(16).toUpperCase().padLeft(2, '0');
    cmds.add("B6" + addr + data);
    addr = ADC_BIT_CONFIG_REG.toRadixString(16).toUpperCase().padLeft(2, '0');
    data = (((adcAvg.index & 0x07) << 4) |
            ((adcSign.index & 0x01) << 3) |
            (adcNBit.index & 0x07))
        .toRadixString(16)
        .toUpperCase()
        .padLeft(2, '0');
    cmds.add("B6" + addr + data);
    addr = ADC_MODE_CONFIG_REG.toRadixString(16).toUpperCase().padLeft(2, '0');
    data = (((adcAutoConvPeriod.index & 0x07) << 4) |
            ((adcAutoResp.index & 0x01) << 2) |
            (adcConvMode.index & 0x03))
        .toRadixString(16)
        .toUpperCase()
        .padLeft(2, '0');
    cmds.add("B6" + addr + data);
    addr = ADC_BUF_CONFIG_REG.toRadixString(16).toUpperCase().padLeft(2, '0');
    data = (((adcBuffer.index & 0x01) << 4) | (adcLPF.index & 0x03))
        .toRadixString(16)
        .toUpperCase()
        .padLeft(2, '0');
    cmds.add("B6" + addr + data);
    addr = ADC_CH_CONFIG_REG.toRadixString(16).toUpperCase().padLeft(2, '0');
    data = (((adcMode.index & 0x01) << 4) |
            ((adcNegChannel.index & 0x03) << 2) |
            (adcPosChannel.index & 0x03))
        .toRadixString(16)
        .toUpperCase()
        .padLeft(2, '0');
    cmds.add("B6" + addr + data);
    addr = ISEN_CONFIG_REG.toRadixString(16).toUpperCase().padLeft(2, '0');
    data = (((isenChannel.index & 0x03) << 4) |
            ((isenDC.index & 0x01) << 2) |
            ((isenVLM.index & 0x01) << 1) |
            (isenRNG.index & 0x01))
        .toRadixString(16)
        .toUpperCase()
        .padLeft(2, '0');
    cmds.add("B6" + addr + data);
    addr = ISEN_VALUE_REG.toRadixString(16).toUpperCase().padLeft(2, '0');
    data = (isenValue & 0x3F).toRadixString(16).toUpperCase().padLeft(2, '0');
    cmds.add("B6" + addr + data);
    addr = VLM_VALUE_REG.toRadixString(16).toUpperCase().padLeft(2, '0');
    data = (vlmValue & 0xFF).toRadixString(16).toUpperCase().padLeft(2, '0');
    cmds.add("B6" + addr + data);
    addr = VDD_CONFIG_REG.toRadixString(16).toUpperCase().padLeft(2, '0');
    data = (vdd.index & 0x01).toRadixString(16).toUpperCase().padLeft(2, '0');
    cmds.add("B6" + addr + data);
    addr = GAP_CMPEN_REG.toRadixString(16).toUpperCase().padLeft(2, '0');
    data = (((cmpenEN.index & 0x01) << 4) | (cmpenTime.index & 0x07))
        .toRadixString(16)
        .toUpperCase()
        .padLeft(2, '0');
    cmds.add("B6" + addr + data);
    return cmds;
  }
}
