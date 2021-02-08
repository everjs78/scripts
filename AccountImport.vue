<template>
  <div class="component account-import">
    <Form class="account-import-form" @submit.prevent="handleSubmit" :freeze="isFetching">
      <ModalDialogContent>
        <DialogTitle>{{ $t('title.account_import') }}</DialogTitle>
        <Fieldset>
          <LabelledInput :label="$t('labels.wif')">
            <Input name="wif" v-model="wif" :placeholder="$t('placeholders.wif')" />
          </LabelledInput>
          <LabelledInput :label="$t('labels.password')">
            <Input name="password" type="password" v-model="password" :placeholder="$t('placeholders.password')" />
          </LabelledInput>
          <LabelledInput :label="$t('labels.name')">
            <Input name="name" v-model="name" :placeholder="$t('placeholders.name')" />
          </LabelledInput>
          <LabelledInput :label="$t('labels.description')">
            <Input
              name="description"
              v-model="description"
              :multiline="true"
              state="optional"
              :placeholder="$t('placeholders.description')"
            />
          </LabelledInput>
        </Fieldset>
      </ModalDialogContent>
      <ModalButtons :canSubmit="filled" :isFetching="isFetching" @cancel="handleCancel" />
    </Form>
  </div>
</template>

<script lang="ts">
import Vue from 'vue';
import { ModalDialogContent } from '@aergoenterprise/lib-components/src/composite';
import { DialogTitle } from '@aergoenterprise/lib-components/src/basic';
import { LabelledInput, Input, Fieldset, Form } from '@aergoenterprise/lib-components/src/composite/forms';
import ModalButtons from '../../../components/buttons/ModalButtons.vue';

export default Vue.extend({
  name: 'UserNew',
  components: {
    ModalDialogContent,
    DialogTitle,
    Fieldset,
    LabelledInput,
    Input,
    ModalButtons,
    Form,
  },
  data() {
    return {
      wif: '',
      password: '',
      name: '',
      description: '',
      isFetching: false,
    };
  },
  methods: {
    handleCancel() {
      this.$emit('close', false);
    },
    handleSubmit(event: Event) {
      this.isFetching = true;
      this.$api
        .postAccounts({
          chain_id: this.$store.getters.chainId,
          name: this.name,
          password: this.password,
          type: 'user-imported',
          wif: this.wif,
          desc: this.description,
        })
        .then(() => {
          this.isFetching = false;
          this.$emit('close', true);
        })
        .catch((error) => {
          this.isFetching = false;
          throw error;
        });
    },
  },
  computed: {
    filled(): boolean {
      return Boolean(this.name) && Boolean(this.wif) && Boolean(this.password);
    },
  },
});
</script>

<style lang="scss">
@import '../../../styles';

.component.account-import {
  .account-import-form {
    @extend %default-form;
  }
}
</style>

<i18n>
{
  "en": {
    "title": {
      "account_import": "Import Account"
    },
    "labels": {
      "wif": "WIF (Wallet Import Format)",
      "password": "Password",
      "name": "Name",
      "description": "Description"
    },
    "placeholders": {
      "wif": "Type WIF to import",
      "password": "Type password",
      "name": "Type name",
      "description": "Type description"
    }
  },
  "ko": {
    "title": {
      "account_import": "계정 가져오기"
    },
    "labels": {
      "wif": "WIF (지갑 가져오기 형식)",
      "password": "비밀번호",
      "name": "이름",
      "description": "설명"
    },
    "placeholders": {
      "wif": "WIF를 입력하세요",
      "password": "비밀번호를 입력하세요",
      "name": "이름을 입력하세요",
      "description": "설명을 입력하세요"
    }
  }
}
</i18n>
