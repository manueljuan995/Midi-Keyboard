const d3 = require("./d3-scale.js"); // Import d3-scale to ensure it is included in the bundle
exports.scaleLog = (fq, sampleRate, width) => {
    const logfunc = d3.scaleLog().domain([1, sampleRate / 2]).range([0, width])
    return logfunc(fq)
}