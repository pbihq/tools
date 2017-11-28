TranscodeVideo
===========
Transcodes a folder's MOV/MP4/MKV files using [FFmpeg][4] on macOS. See script for transcoding details and applied audio filters. Transmuxes FLV files to MP4 first, if found. You need to have FFmpeg [installed][5] to use this.

Transcode to H.264:

    bash <(curl -s https://raw.githubusercontent.com/pbihq/tools/master/TranscodeVideo/TranscodeVideoH264.sh)

Transcode to MPEG1:

    bash <(curl -s https://raw.githubusercontent.com/pbihq/tools/master/TranscodeVideo/TranscodeVideoMPEG1.sh)

Transcode to MPEG2:

    bash <(curl -s https://raw.githubusercontent.com/pbihq/tools/master/TranscodeVideo/TranscodeVideoMPEG2.sh)

Transcode to WMV:

    bash <(curl -s https://raw.githubusercontent.com/pbihq/tools/master/TranscodeVideo/TranscodeVideoWMV.sh)


[4]: https://ffmpeg.org/
[5]: https://trac.ffmpeg.org/wiki/CompilationGuide/MacOSX
