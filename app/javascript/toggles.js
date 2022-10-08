import Vue from 'vue/dist/vue.esm.js';

if(document.querySelector('#schedule-toggle')){
  new Vue({
    el: '#schedule-toggle',
    data(){
      return{
        isOpen: false
      };
    },
    methods:{
      toggleAccordion(){
        this.isOpen = !this.isOpen;
      }
    }
  });
}