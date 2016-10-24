{Mixer, Unzipper, Zipper, FMT_F32LE, FMT_S16LE, FMT_U16LE}  = require "lbmrn-pcm-utils"


class MultichannelMixer extends Zipper
  formats: {FMT_F32LE, FMT_S16LE, FMT_U16LE}

  constructor: (streams = [], {@channels, @format}) ->
    @channels or= 2
    format    or= FMT_S16LE

    super {@channels, @format}

    @streams    = []
    @_unzippers = []
    @_mixers    = for i in [1..@channels]
      mixer = new Mixer @channels, @format
      mixer[i].pipe @inputs[i]

    @add streams...

  add: (streams...) ->
    for stream in streams
      unzipper = new Unzipper @channels, @format
      @unzippers.push unzipper
      @streams.push stream
      stream.pipe unzipper
      unzipper.outputs[i].pipe @_mixers[i] for i in [1..@channels]

  remove: (streams...) ->
    for stream in streams
      index = @streams.indexOf stream
      throw new Error "stream not found" unless index > -1
      @streams.splice index, 1
      unzipper = @_unzippers.splice index, 1
      stream.unpipe unzipper
      unzipper.outputs[i].unpipe @_mixers[i] for i in [1..@channels]


module.exports = MultichannelMixer
