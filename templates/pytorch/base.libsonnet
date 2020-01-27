local base = import "../base.libsonnet";

{
  PyTorchTest:: base.BaseTest {

    regressionTestConfig+: {
      threshold_expression_overrides: {
        "Accuracy/test_final": "v_mean - (v_stddev * 3.0)"
      },
      comparison_overrides: {
        "Accuracy/test_final": "COMPARISON_LT"
      }
    },

    image: "gcr.io/xl-ml-test/pytorch-xla",
    jobSpec+:: {
      template+: {
        spec+: {
          volumes: [
            {
              name: "dshm",
              emptyDir: {
                medium: "Memory",
              },
            },
            {
              name: "datasets-pd",
              gcePersistentDisk: {
                pdName: "pytorch-datasets-pd-central1-b",
                fsType: "ext4",
              },
            },
          ],
          containers: [
            container {
              args+: ["--logdir=$(MODEL_DIR)" ],
              volumeMounts: [{
                mountPath: "/dev/shm",
                name: "dshm",
              }],
              env+: [{
                name: "XLA_USE_BF16",
                value: "0",
              }],
              resources+: {
                requests+: {
                  cpu: "4.5",
                  memory: "8Gi",
                },
              },
            } for container in super.containers
          ],
        },
      },
    },
  },
}