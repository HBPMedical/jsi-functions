FROM registry.federation.mip.hbp/mip_base/r-job:latest

MAINTAINER ludovic.claude54@gmail.com

LABEL eu.humanbrainproject.function=summary-stats \
      eu.humanbrainproject.function.location=node \
      eu.humanbrainproject.function.version=0.1 \
      eu.humanbrainproject.function.author="Bernard Zenko" \
      eu.humanbrainproject.function.organisation="E8, JSI" \
      eu.humanbrainproject.function.date="2016-01-21"

COPY main.R /src/
COPY clus.jar /src/
COPY commons-math-1.0.jar /src/
COPY jgap.jar /src/



RUN installGithub.r &lt;foreign&gt;
