#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/runtime:6.0 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["twitch2tuner/twitch2tuner.csproj", "twitch2tuner/"]
RUN dotnet restore "twitch2tuner/twitch2tuner.csproj"
COPY . .
WORKDIR "/src/twitch2tuner"
RUN dotnet build "twitch2tuner.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "twitch2tuner.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

RUN apt-get update && \
    (apt-get install -y python3-pip ffmpeg || (sleep 10 && apt-get install -y --fix-missing python3-pip ffmpeg)) && \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["dotnet", "twitch2tuner.dll"]
