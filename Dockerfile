# hadolint global ignore=DL3008
FROM debian:12-slim AS build 

# Définir l'encodage UTF-8 comme configuration globale
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV PYTHONIOENCODING=utf-8

# Installation des dépendances nécessaires
RUN apt-get update && \
    apt-get install --no-install-suggests --no-install-recommends --yes \
    python3-venv \
    python3-pip \
    gcc \
    libpython3-dev \
    locales && \
    # Configurer les locales pour UTF-8
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 && \
    # Créer l'environnement virtuel avec UTF-8 explicite
    python3 -m venv /venv && \
    # Mise à jour de pip dans l'environnement virtuel
    /venv/bin/pip install --upgrade pip && \
    # Nettoyer pour réduire la taille de l'image
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

FROM build AS build-venv

COPY requirements.txt /requirements.txt
RUN /venv/bin/pip install --disable-pip-version-check -r /requirements.txt

FROM gcr.io/distroless/python3-debian12:latest-amd64
# Copier les paramètres d'environnement
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV PYTHONIOENCODING=utf-8

COPY --from=build-venv /venv /venv

WORKDIR /app

COPY . .

EXPOSE 8080

# Utiliser la forme ENTRYPOINT+CMD pour plus de clarté
ENTRYPOINT ["/venv/bin/python"]
CMD ["manage.py", "runserver", "0.0.0.0:8080"]