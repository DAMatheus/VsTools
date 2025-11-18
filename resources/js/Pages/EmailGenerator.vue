<template>
  <div class="flex justify-center py-10 px-4 bg-zinc-900 min-h-screen">
    <Card class="w-full max-w-2xl p-4 shadow-xl border border-yellow-400/50 bg-zinc-800 text-white">

      <!-- TÍTULO -->
      <template #title>
        <h1 class="text-3xl font-bold text-center text-yellow-400 drop-shadow">
          Gerador de Email VS Tools
        </h1>
      </template>

      <!-- FORM -->
      <template #content>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 text-white">

          <!-- Implantação -->
          <div class="flex flex-col gap-1">
            <label class="font-semibold">Tipo de Implantação</label>
            <Dropdown v-model="form.implantacao" :options="implantacaoOptions"
              optionLabel="label" optionValue="value" class="w-full" />
          </div>

          <!-- Razão Social -->
          <div class="flex flex-col gap-1 md:col-span-2">
            <label class="font-semibold">Razão Social</label>
            <InputText v-model="form.razao_social" class="w-full" />
          </div>

          <!-- Número do pedido -->
          <div class="flex flex-col gap-1">
            <label class="font-semibold">Número do Pedido</label>
            <InputText v-model="form.num_pedido" type="number" class="w-full" />
          </div>

          <!-- Vendedor -->
          <div class="flex flex-col gap-1">
            <label class="font-semibold">Vendedor</label>
            <Dropdown v-model="form.vendedor" :options="vendedores" class="w-full" />
          </div>

          <!-- Seriais + TeamViewer -->
          <div class="md:col-span-2">
            <label class="font-semibold text-lg">Seriais e TeamViewer</label>

            <div v-for="(item, index) in form.seriais" :key="index"
              class="grid grid-cols-1 md:grid-cols-3 gap-4 items-end bg-zinc-700 p-4 rounded border border-yellow-400/30 mt-3">
              <div class="flex flex-col gap-1">
                <label class="font-semibold">Serial</label>
                <InputText v-model="form.seriais[index]" class="w-full" />
              </div>

              <div class="flex flex-col gap-1">
                <label class="font-semibold">TeamViewer</label>
                <InputText v-model="form.teamviewers[index]" class="w-full" />
              </div>

              <Button icon="pi pi-trash" severity="danger" class="w-full"
                @click="removeLinha(index)" v-if="form.seriais.length > 1" />
            </div>

            <Button label="Adicionar Linha" icon="pi pi-plus"
              class="mt-3 w-full !bg-yellow-500 !border-yellow-400 !text-black font-bold !hover:bg-yellow-400"
              @click="addLinha" />
          </div>

          <!-- Impressora -->
          <div class="flex flex-col gap-1 md:col-span-2">
            <label class="font-semibold">Impressora</label>
            <Dropdown v-model="form.impressora" :options="impressoras" class="w-full" />
          </div>
        </div>

        <Button label="Gerar Email"
          class="mt-6 w-full !bg-yellow-500 !text-black font-bold !hover:bg-yellow-400 !border-yellow-400"
          @click="submit" />
      </template>

    </Card>

    <!-- MODAL -->
    <Dialog
      v-model:visible="showModal"
      modal
      header="Email Gerado"
      class="w-full max-w-xl bg-black text-white border border-yellow-400"
      :pt="{
        header: { class: 'bg-black text-yellow-400 font-bold text-xl border-b border-yellow-400' },
        content: { class: 'bg-black text-white' },
        footer: { class: 'bg-black border-t border-yellow-400' }
      }"
    >
      <div class="space-y-6">

        <!-- ASSUNTO -->
        <div>
          <p class="font-semibold text-yellow-400 mb-1">Assunto:</p>

          <div class="relative bg-zinc-900 p-3 rounded border border-yellow-400 text-sm pr-12">
            {{ tituloLocal }}

            <button
              @click="copiarComFeedback(tituloLocal, 'titulo')"
              class="absolute top-1/2 -translate-y-1/2 right-3 text-yellow-400 hover:text-yellow-200"
            >
              <i class="pi pi-copy text-xl"></i>
            </button>

            <span
              v-if="copiado.titulo"
              class="absolute right-12 top-1/2 -translate-y-1/2 text-green-400 text-xs animate-pulse"
            >
              copiado!
            </span>
          </div>
        </div>

        <!-- DESTINATÁRIOS -->
        <div>
          <p class="font-semibold text-yellow-400 mb-1">Enviar para:</p>

          <div class="relative bg-zinc-900 p-3 rounded border border-yellow-400 text-sm pr-12 whitespace-pre-line">
            {{ emailsDestinatarios }}

            <button
              @click="copiarComFeedback(emailsDestinatarios, 'destinatarios')"
              class="absolute top-2 right-3 text-yellow-400 hover:text-yellow-200"
            >
              <i class="pi pi-copy text-xl"></i>
            </button>

            <span
              v-if="copiado.destinatarios"
              class="absolute right-12 top-2 text-yellow-400 text-xs animate-pulse"
            >
              copiado!
            </span>
          </div>
        </div>

        <!-- CORPO -->
        <div>
          <p class="font-semibold text-yellow-400 mb-1">Corpo do Email:</p>

          <div class="relative">
            <pre class="bg-zinc-900 p-3 rounded border border-yellow-400 whitespace-pre-line text-sm pr-12">
{{ corpoLocal }}
            </pre>

            <button
              @click="copiarComFeedback(corpoLocal, 'corpo')"
              class="absolute top-2 right-3 text-yellow-400 hover:text-yellow-200"
            >
              <i class="pi pi-copy text-xl"></i>
            </button>

            <span
              v-if="copiado.corpo"
              class="absolute right-12 top-2 text-yellow-400 text-xs animate-pulse"
            >
              copiado!
            </span>
          </div>
        </div>

        <Button label="Fechar" class="w-full !bg-red-600 !border-red-500 !text-white"
          @click="showModal = false" />
      </div>

    </Dialog>
  </div>
</template>

<script setup>
import { useForm } from "@inertiajs/vue3";
import { ref } from "vue";
import axios from "axios";

const implantacaoOptions = [
  { label: "Implantação em fábrica", value: "fábrica" },
  { label: "Implantação no cliente", value: "cliente" },
];

const vendedores = ["Ifood", "Igor", "Rauber"];
const impressoras = ["T88", "T20", "T33"];

const form = useForm({
  implantacao: "fábrica",
  razao_social: "",
  num_pedido: "",
  vendedor: "Ifood",
  seriais: [""],
  teamviewers: [""],
  impressora: "T88",
});

const addLinha = () => {
  form.seriais.push("");
  form.teamviewers.push("");
};

const removeLinha = (index) => {
  if (form.seriais.length > 1) {
    form.seriais.splice(index, 1);
    form.teamviewers.splice(index, 1);
  }
};

const showModal = ref(false);
const tituloLocal = ref("");
const corpoLocal = ref("");

// emails fixos
const emailsDestinatarios = `
lucas.bressan@ifood.com.br
implantacao@ifood.com.br
pcp@videosoft.com.br
assistencia@videosoft.com.br
`;

// feedback de cópia
const copiado = ref({
  titulo: false,
  corpo: false,
  destinatarios: false,
});

const copiarComFeedback = async (texto, campo) => {
  await navigator.clipboard.writeText(texto);
  copiado.value[campo] = true;

  setTimeout(() => {
    copiado.value[campo] = false;
  }, 1200);
};

// SUBMIT AJAX — sem mudar URL
const submit = async () => {
  const response = await axios.post(route("email.generate"), form);

  tituloLocal.value = response.data.titulo;
  corpoLocal.value = response.data.corpo;

  showModal.value = true;
};
</script>

<style scoped>
.p-inputtext:focus,
.p-dropdown:focus,
.p-dropdown.p-focus,
.p-inputwrapper-focus,
.p-focus {
  --p-focus-ring-color: #ffffff !important;
  border-color: #ffffff !important;
  box-shadow: 0 0 0 1px #ffffff !important;
}
</style>
