#!/bin/bash
#David Benjamin Ayala Giralt
export KOPS_STATE_STORE=s3://se-benjamin/kops
kops delete cluster davidayala.k8s.local --yes