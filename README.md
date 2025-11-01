# Terraform - Infraestructura como Código

Este repositorio contiene la configuración de Terraform para desplegar la infraestructura de Azure necesaria para los microservicios.

## Estructura

```
ecommerce-terraform-infra/
├── environments/        # Configuración por ambiente
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── terraform.tfvars.example
│   ├── stage/
│   └── prod/
├── modules/             # Módulos reutilizables (futuro)
│   ├── aks/
│   ├── networking/
│   └── storage/
├── .gitignore
└── README.md
```

## ¿Por qué Terraform?

Según el proyecto final, se requiere:
- ✅ Configurar infraestructura usando Terraform
- ✅ Implementar estructura modular
- ✅ Configuración para múltiples ambientes (dev, stage, prod)
- ✅ Backend remoto para el estado de Terraform

## Recursos Desplegados

Los módulos de Terraform crean:
- Resource Group
- Virtual Network y Subnet
- Azure Kubernetes Service (AKS)
- (Futuro: Storage, Networking, etc.)

## Uso

### Inicializar Terraform

```bash
cd environments/dev
terraform init
```

### Plan

```bash
terraform plan
```

### Aplicar

```bash
terraform apply
```

### Destruir (con cuidado!)

```bash
terraform destroy
```

## Configuración

1. Copia `environments/dev/terraform.tfvars.example` a `terraform.tfvars`
2. Configura los valores según tu entorno
3. **NO commitees `terraform.tfvars`** - está en `.gitignore`

## Backend Remoto

El backend remoto (Azure Storage) está comentado en `main.tf`. Para usarlo:

1. Crea un Storage Account en Azure
2. Crea un contenedor `tfstate`
3. Descomenta y configura el backend en `main.tf`

## Variables

- `location`: Región de Azure (default: `eastus`)
- `kubernetes_version`: Versión de Kubernetes (default: `1.28`)
- `node_count`: Número de nodos (default: `2`)
- `node_size`: Tamaño de los nodos (default: `Standard_B2s`)

## Próximos Pasos

1. ✅ Configuración base para dev
2. ⏳ Crear módulo base para AKS
3. ⏳ Configurar ambientes stage y prod
4. ⏳ Integrar con GitHub Actions para despliegue automático
5. ⏳ Configurar backend remoto (Azure Storage)
