
#
# BACK END
# BUILD
#

FROM microsoft/dotnet:2.2-sdk AS backend
#FROM microsoft/dotnet:2.2-sdk-stretch-arm32v7 AS backend
WORKDIR /testcoreweb
COPY testcoreweb ./
RUN dotnet restore
RUN dotnet build -c Release
RUN dotnet publish -c Release

#
# FRONT-END
# RESTORE
#

FROM node:8 as front-end-restore
WORKDIR /app
COPY testapp /app
RUN npm install

#
# FRONT-END
# BUILD
#

FROM front-end-restore as front-end-build
RUN npm rebuild node-sass
RUN npm run build --prod --aot

#
# FINAL
#

#FROM microsoft/dotnet:2.2-aspnetcore-runtime AS final
FROM microsoft/dotnet:2.2-aspnetcore-runtime-stretch-slim-arm32v7
WORKDIR /app
COPY --from=backend /testcoreweb/testcoreweb/bin/Release/netcoreapp2.2/publish /app
COPY --from=front-end-build app/dist/testapp /app/wwwroot
CMD ["dotnet", "/app/testcoreweb.dll"]
