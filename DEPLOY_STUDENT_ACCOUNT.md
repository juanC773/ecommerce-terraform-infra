# Guía de Despliegue - Cuenta Estudiante de Azure

Esta guía te ayudará a desplegar la infraestructura con una cuenta de estudiante de Azure, optimizada para los límites y créditos disponibles.

## Limitaciones de Cuenta Estudiante

Las cuentas de estudiante de Azure típicamente tienen:
- 💰 Créditos limitados: $100-$200 USD
- 📊 Límites en tipos de recursos
- 🚫 Algunos tamaños de VM no disponibles (series premium)
- ⏱️ Duración limitada (12 meses típicamente)

## Configuración Optimizada

Esta configuración usa:
- ✅ **Standard_B2s**: El tamaño más pequeño y económico disponible
- ✅ **1 nodo por pool**: Mínimo necesario para funcionar
- ✅ **Un solo cluster**: Comparte recursos entre ambientes
- ✅ **Node pools con taints**: Separa ambientes dentro del mismo cluster

## Costo Estimado (Aproximado)

Con esta configuración:
- **3 nodos totales** (1 system + 1 prod + 1 devstage) × Standard_B2s
- **Costo aproximado**: ~$50-80 USD/mes
- **Con $100 de crédito**: ~1-2 meses de uso

## Pasos para Desplegar

### 1. Verificar Tu Cuenta de Azure

```bash
# Verificar que estás logueado
az account show

# Ver créditos disponibles (si es posible)
az consumption budget list
```

### 2. Verificar Disponibilidad de Recursos

```bash
# Ver tamaños de VM disponibles en tu región
az vm list-sizes --location "East US 2" --output table

# Verificar que Standard_B2s esté disponible
az vm list-sizes --location "East US 2" --query "[?name=='Standard_B2s']"
```

Si `Standard_B2s` no está disponible, prueba con:
- `Standard_B1s` (más pequeño, pero puede ser muy limitado)
- `Standard_B2ms` (un poco más grande)

### 3. Configurar Variables

```bash
cd ecommerce-terraform-infra
cp terraform.tfvars.example terraform.tfvars
```

Edita `terraform.tfvars` y asegúrate de que todo use `Standard_B2s`:

```hcl
default_node_pool = {
  name       = "system"
  node_count = 1
  vm_size    = "Standard_B2s"
}

prod_node_pool = {
  vm_size    = "Standard_B2s"
  node_count = 1
}

devstage_node_pool = {
  vm_size    = "Standard_B2s"
  node_count = 1
}
```

### 4. Inicializar Terraform

```bash
terraform init
```

### 5. Verificar el Plan (MUY IMPORTANTE)

```bash
terraform plan
```

**Revisa cuidadosamente:**
- ✅ Que solo se creen 3 nodos (1 + 1 + 1)
- ✅ Que todos usen `Standard_B2s`
- ✅ Que el resource group tenga un nombre que puedas identificar

### 6. Desplegar

```bash
terraform apply
```

Tendrás que escribir `yes` para confirmar.

⏱️ **Tiempo estimado**: 10-15 minutos

### 7. Configurar kubectl

```bash
# Usar el comando del output
terraform output -raw get_kubectl_config_command | bash

# O manualmente
az aks get-credentials --resource-group ecommerce-rg --name ecommerce-aks
```

### 8. Verificar el Cluster

```bash
# Ver los nodos
kubectl get nodes

# Deberías ver 3 nodos (uno de cada pool)

# Ver los node pools
kubectl get nodes --show-labels | grep environment
```

## Troubleshooting Común

### Error: "The subscription does not have enough quota"

**Solución**: Reduce el número de nodos o usa un tamaño más pequeño.

Edita `terraform.tfvars`:
```hcl
# Reduce a 0 nodos iniciales (se escalará cuando sea necesario)
prod_node_pool = {
  vm_size    = "Standard_B2s"
  node_count = 0  # Escala manualmente después si es necesario
}
```

### Error: "VM size Standard_B2s is not available"

**Solución**: Usa otro tamaño disponible:

```bash
# Ver tamaños disponibles
az vm list-sizes --location "East US 2" --query "[?starts_with(name, 'Standard_B')]" --output table
```

Luego actualiza `terraform.tfvars` con el tamaño disponible.

### Error: "Insufficient funds"

**Solución**: 
- Verifica tus créditos en Azure Portal
- Considera reducir aún más los recursos
- Usa `Standard_B1s` si está disponible

### El cluster tarda mucho en crear

**Normal**: Crear un cluster de AKS puede tomar 10-20 minutos. Sé paciente.

## Optimización de Costos

### Reducir Nodos cuando no los uses

```bash
# Escalar a 0 cuando no trabajes
az aks nodepool scale \
  --resource-group ecommerce-rg \
  --cluster-name ecommerce-aks \
  --name devstage \
  --node-count 0

# Escalar de vuelta cuando necesites
az aks nodepool scale \
  --resource-group ecommerce-rg \
  --cluster-name ecommerce-aks \
  --name devstage \
  --node-count 1
```

### Destruir cuando no lo uses

```bash
# Guardar el estado por si acaso
terraform state pull > backup-state.json

# Destruir todo
terraform destroy

# Cuando necesites volver, solo aplica de nuevo
terraform apply
```

## Monitoring de Costos

```bash
# Ver costos estimados (requiere configuración adicional)
az consumption usage list --start-date 2024-01-01

# O mejor, usa Azure Portal:
# Portal → Cost Management → Cost Analysis
```

## Próximos Pasos

Una vez que el cluster esté funcionando:

1. ✅ Configurar namespaces por ambiente
2. ✅ Desplegar Service Discovery
3. ✅ Desplegar Cloud Config
4. ✅ Desplegar Product Service
5. ✅ Configurar los workflows de GitHub Actions

¡Todo listo para empezar a desplegar! 🚀

