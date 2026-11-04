$ErrorActionPreference = "Stop"

Write-Host "=== PRACTICA DE GIT - Iker Fuentes ===" -ForegroundColor Cyan

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "Git no está instalado o no está agregado al PATH. Instala Git desde https://git-scm.com/download/win y vuelve a ejecutar este archivo."
}

# Identidad solicitada en la guía del taller
git config --local user.name "Iker Fuentes"
git config --local user.email "fuentesiker50@gmail.com"

# Evita reinicializar accidentalmente un repositorio existente
if (Test-Path ".git") {
    throw "Esta carpeta ya contiene un repositorio Git. Para evitar sobrescribir trabajo, el script se detuvo."
}

git init -b main
if ($LASTEXITCODE -ne 0) { throw "No se pudo inicializar Git." }

git add .
git commit -m "Primer commit: proyecto inicial Carro"
if ($LASTEXITCODE -ne 0) { throw "No se pudo crear el primer commit." }

$initialCommit = (git rev-parse HEAD).Trim()

# Segundo cambio: se modifica el comportamiento de acelerar
$carroV2 = @'
public class Carro {
    private int velocidad;

    public Carro() {
        velocidad = 0;
    }

    public void acelerar() {
        velocidad += 20;
        System.out.println("El carro acelera. Velocidad actual: " + velocidad + " km/h");
    }

    public static void main(String[] args) {
        Carro miCarro = new Carro();
        miCarro.acelerar();
        miCarro.acelerar();
    }
}
'@
Set-Content -Path "src/Carro.java" -Value $carroV2 -Encoding UTF8
git add src/Carro.java
git commit -m "Modificar incremento de velocidad"
if ($LASTEXITCODE -ne 0) { throw "No se pudo crear el segundo commit." }

# Recupera el archivo tal como estaba en el primer commit y registra esa recuperación
git restore --source=$initialCommit -- src/Carro.java
git add src/Carro.java
git commit -m "Restaurar versión inicial de Carro"
if ($LASTEXITCODE -ne 0) { throw "No se pudo registrar la restauración." }

# Crea una rama, agrega frenar(), y luego la integra a main
git switch -c rama-frenar
if ($LASTEXITCODE -ne 0) { throw "No se pudo crear rama-frenar." }

$carroConFreno = @'
public class Carro {
    private int velocidad;

    public Carro() {
        velocidad = 0;
    }

    public void acelerar() {
        velocidad += 10;
        System.out.println("El carro acelera. Velocidad actual: " + velocidad + " km/h");
    }

    public void frenar() {
        velocidad = Math.max(0, velocidad - 10);
        System.out.println("El carro frena. Velocidad actual: " + velocidad + " km/h");
    }

    public static void main(String[] args) {
        Carro miCarro = new Carro();
        miCarro.acelerar();
        miCarro.acelerar();
        miCarro.frenar();
    }
}
'@
Set-Content -Path "src/Carro.java" -Value $carroConFreno -Encoding UTF8
git add src/Carro.java
git commit -m "Agregar método frenar en rama-frenar"
if ($LASTEXITCODE -ne 0) { throw "No se pudo crear el commit de la rama." }

git switch main
if ($LASTEXITCODE -ne 0) { throw "No se pudo regresar a main." }
git merge rama-frenar --no-edit
if ($LASTEXITCODE -ne 0) { throw "No se pudo fusionar rama-frenar." }
git branch -d rama-frenar
if ($LASTEXITCODE -ne 0) { throw "No se pudo borrar la rama local." }

Write-Host "`nHistorial creado:" -ForegroundColor Green
git --no-pager log --oneline --decorate

# Publicación: usa GitHub CLI para autenticar y crear/conectar el repositorio.
$repo = "fuentesiker/practica-git"
if (Get-Command gh -ErrorAction SilentlyContinue) {
    gh auth status 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "`nSe abrirá el proceso oficial de inicio de sesión de GitHub." -ForegroundColor Yellow
        gh auth login --hostname github.com --git-protocol https --web
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "No se completó el inicio de sesión. El repositorio local quedó listo; puedes publicar después."
            exit 0
        }
    }

    gh repo view $repo 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
        gh repo create $repo --public --source . --remote origin
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "No se pudo crear el repositorio remoto. El trabajo local quedó guardado."
            exit 0
        }
    } else {
        $remote = git remote get-url origin 2>$null
        if ($LASTEXITCODE -ne 0) {
            git remote add origin "https://github.com/$repo.git"
        } elseif ($remote -ne "https://github.com/$repo.git") {
            git remote set-url origin "https://github.com/$repo.git"
        }
    }

    git push -u origin main
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Los commits están guardados localmente, pero no se pudo completar el push."
    } else {
        Write-Host "`n¡Proyecto publicado! https://github.com/$repo" -ForegroundColor Green
    }
} else {
    Write-Warning "No se encontró GitHub CLI (gh). El proyecto y todos los commits quedaron listos localmente. Para publicar automáticamente, instala GitHub CLI desde https://cli.github.com/ y vuelve a ejecutar la parte de publicación."
}

Write-Host "`nTerminado. Abre PracticaGit en NetBeans para revisar y ejecutar la clase Carro." -ForegroundColor Cyan


